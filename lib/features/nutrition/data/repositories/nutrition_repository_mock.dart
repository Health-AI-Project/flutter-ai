import 'dart:async';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/repositories/nutrition_repository.dart';

class NutritionRepositoryMock implements NutritionRepository {
  @override
  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String userId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return const MealAnalysis(
      foods: [
        FoodItem(
            name: 'Riz blanc',
            calories: 206,
            proteins: 4.3,
            carbs: 45.0,
            fats: 0.4),
        FoodItem(
            name: 'Poulet grillé',
            calories: 165,
            proteins: 31.0,
            carbs: 0.0,
            fats: 3.6),
        FoodItem(
            name: 'Brocoli vapeur',
            calories: 55,
            proteins: 3.7,
            carbs: 11.2,
            fats: 0.6),
      ],
      totalCalories: 426,
      totalProteins: 39.0,
      totalCarbs: 56.2,
      totalFats: 4.6,
      suggestions: [
        'Bon équilibre protéines/glucides pour un repas post-entraînement.',
        'Pensez à ajouter une source de graisses saines (avocat, huile d\'olive).',
        'Hydratez-vous bien après ce repas.',
      ],
    );
  }
}
