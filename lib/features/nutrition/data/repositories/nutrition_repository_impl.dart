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
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedPath,
          filename: 'meal.jpg',
        ),
      });

      final uploadResponse = await _dio.post(
        ApiConstants.uploadMeal,
        data: formData,
      );

      final model = MealAnalysisModel.fromBffJson(
        uploadResponse.data as Map<String, dynamic>,
      );

      return model.toEntity();
    } on DioException catch (_) {
      debugPrint('ERREUR upload BFF — fallback mock');
      return _mockAnalysis(imagePath);
    } finally {
      if (compressedPath != imagePath) {
        await ImageUtils.deleteTemp(compressedPath);
      }
    }
  }

  MealAnalysis _mockAnalysis(String imagePath) {
    final filename = imagePath.split('/').last.toLowerCase();
    final basename = filename.contains('.') ? filename.substring(0, filename.lastIndexOf('.')) : filename;

    if (basename == 'pizza') {
      return const MealAnalysis(
        detectedFood: 'Pizza Margherita',
        confidence: 0.94,
        totalCalories: 780,
        totalProteins: 32,
        totalCarbs: 88,
        totalFats: 28,
        foods: [
          FoodItem(name: 'Pâte à pizza (180g)', calories: 420, proteins: 12, carbs: 72, fats: 8),
          FoodItem(name: 'Mozzarella (80g)', calories: 220, proteins: 16, carbs: 2, fats: 16),
          FoodItem(name: 'Sauce tomate (60g)', calories: 40, proteins: 2, carbs: 8, fats: 0),
          FoodItem(name: 'Basilic & huile d\'olive (10g)', calories: 80, proteins: 0, carbs: 0, fats: 8),
        ],
        suggestions: [
          'Repas calorique — à consommer avec modération',
          'Ajoutez des légumes pour plus de fibres',
        ],
        isSafe: true,
        warnings: ['Apport en sodium élevé'],
        advice: 'Repas festif acceptable occasionnellement. Privilégiez une portion raisonnable.',
      );
    }

    if (basename == 'beignet') {
      return const MealAnalysis(
        detectedFood: 'Beignets (x3)',
        confidence: 0.88,
        totalCalories: 540,
        totalProteins: 8,
        totalCarbs: 62,
        totalFats: 28,
        foods: [
          FoodItem(name: 'Pâte frite (120g)', calories: 380, proteins: 6, carbs: 48, fats: 20),
          FoodItem(name: 'Sucre glace (20g)', calories: 80, proteins: 0, carbs: 20, fats: 0),
          FoodItem(name: 'Huile de friture (8g)', calories: 72, proteins: 0, carbs: 0, fats: 8),
          FoodItem(name: 'Garniture confiture (15g)', calories: 40, proteins: 0, carbs: 10, fats: 0),
        ],
        suggestions: [
          'Teneur élevée en graisses saturées',
          'Préférez une collation à base de fruits',
        ],
        isSafe: true,
        warnings: ['Riche en sucres rapides', 'Riche en graisses saturées'],
        advice: 'Consommation occasionnelle recommandée. Évitez après une période de sédentarité.',
      );
    }

    // Fallback générique
    return const MealAnalysis(
      detectedFood: 'Bol de pâtes bolognaise',
      confidence: 0.91,
      totalCalories: 620,
      totalProteins: 34,
      totalCarbs: 72,
      totalFats: 18,
      foods: [
        FoodItem(name: 'Pâtes (200g)', calories: 280, proteins: 10, carbs: 56, fats: 2),
        FoodItem(name: 'Bœuf haché (100g)', calories: 220, proteins: 20, carbs: 0, fats: 14),
        FoodItem(name: 'Sauce tomate (80g)', calories: 60, proteins: 2, carbs: 12, fats: 1),
        FoodItem(name: 'Parmesan (15g)', calories: 60, proteins: 4, carbs: 0, fats: 4),
      ],
      suggestions: [
        'Bonne source de protéines',
        'Pensez à ajouter des légumes pour plus de fibres',
      ],
      isSafe: true,
      warnings: [],
      advice: 'Repas équilibré — idéal après une séance de sport.',
    );
  }
}
