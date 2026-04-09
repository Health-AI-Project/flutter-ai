import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (ref) => MealPlanRepositoryImpl(),
);

class MealPlanNotifier extends AsyncNotifier<GeneratedMealPlan?> {
  @override
  Future<GeneratedMealPlan?> build() async => null;

  Future<void> generate({
    required int calories,
    required List<String> allergies,
    required String goal,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(mealPlanRepositoryProvider).generateMealPlan(
            dailyCaloriesTarget: calories,
            allergies: allergies,
            goal: goal,
          );
    });
  }

  void reset() => state = const AsyncData(null);
}

final mealPlanProvider =
    AsyncNotifierProvider<MealPlanNotifier, GeneratedMealPlan?>(
  MealPlanNotifier.new,
);
