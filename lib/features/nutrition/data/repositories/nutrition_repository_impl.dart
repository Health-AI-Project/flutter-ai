import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../models/meal_analysis_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String userId,
  }) async {
    final compressedPath = await ImageUtils.compress(imagePath);

    try {
      // Étape 1 : upload de l'image → macros brutes
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedPath,
          filename: 'meal.jpg',
        ),
        'userId': userId,
      });

      final uploadResponse = await _dio.post(
        ApiConstants.uploadMeal,
        data: formData,
      ).catchError((e) {
        if (e is DioException && e.response?.statusCode == 500) {
          throw Exception('Service d\'analyse indisponible. Réessaie plus tard.');
        }
        throw e;
      });

      MealAnalysisModel model = MealAnalysisModel.fromUploadJson(
        uploadResponse.data as Map<String, dynamic>,
      );

      // Étape 2 : analyse IA → is_safe, warnings, advice
      try {
        final analyzeResponse = await _dio.post(
          ApiConstants.analyzeMeal,
          data: {
            'ingredients': ['meal'],
            'macros': {
              'calories': model.totalCalories.toInt(),
              'protein': model.totalProteins.toInt(),
              'carbs': model.totalCarbs.toInt(),
              'fat': model.totalFats.toInt(),
            },
          },
        );

        final aiData = analyzeResponse.data as Map<String, dynamic>;
        model = model.withAiAnalysis(
          isSafe: aiData['is_safe'] as bool? ?? true,
          warnings: (aiData['warnings'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          advice: aiData['advice'] as String? ?? '',
        );
      } catch (e) {
        // L'analyse IA est non-bloquante : on retourne les macros même si elle échoue
        debugPrint('WARN : analyse IA échouée (non-bloquant) — $e');
      }

      return model.toEntity();
    } finally {
      // Ne supprimer que si c'est un fichier temporaire créé par compress()
      if (compressedPath != imagePath) {
        await ImageUtils.deleteTemp(compressedPath);
      }
    }
  }
}
