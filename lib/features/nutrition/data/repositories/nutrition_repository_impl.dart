import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../models/meal_analysis_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  // Appel direct au service Python — le BFF n'expose pas encore le bon endpoint
  final Dio _pythonDio = Dio(BaseOptions(
    baseUrl: ApiConstants.pythonServiceUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
  ));

  @override
  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String userId,
  }) async {
    final compressedPath = await ImageUtils.compress(imagePath);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedPath,
          filename: 'meal.jpg',
        ),
        'top_k': '3',
      });

      final uploadResponse = await _pythonDio.post(
        '/predict/upload',
        data: formData,
      );

      final model = MealAnalysisModel.fromPythonJson(
        uploadResponse.data as Map<String, dynamic>,
      );

      return model.toEntity();
    } on DioException catch (e) {
      debugPrint('ERREUR upload Python service — $e');
      throw Exception('Service d\'analyse indisponible. Réessaie plus tard.');
    } finally {
      if (compressedPath != imagePath) {
        await ImageUtils.deleteTemp(compressedPath);
      }
    }
  }
}
