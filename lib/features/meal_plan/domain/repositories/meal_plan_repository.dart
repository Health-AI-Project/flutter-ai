import '../entities/meal_plan.dart';

abstract class MealPlanRepository {
  Future<GeneratedMealPlan> generateMealPlan({
    required int dailyCaloriesTarget,
    required List<String> allergies,
    required String goal,
  });
}
