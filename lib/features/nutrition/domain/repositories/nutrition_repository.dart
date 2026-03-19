import '../entities/meal_analysis.dart';

abstract class NutritionRepository {
  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String userId,
  });
}
