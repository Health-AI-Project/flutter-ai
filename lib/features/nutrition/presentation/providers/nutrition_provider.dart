import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../data/repositories/nutrition_repository_mock.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepositoryMock(), // TODO: remplacer par NutritionRepositoryImpl() en prod
);

class NutritionNotifier extends AsyncNotifier<MealAnalysis?> {
  @override
  Future<MealAnalysis?> build() async => null;

  Future<void> analyzeMeal(String imagePath, String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(nutritionRepositoryProvider);
      return repo.analyzeMeal(imagePath: imagePath, userId: userId);
    });
  }

  void updateFoodItem(int index, MealAnalysis updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(updated);
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final nutritionProvider =
    AsyncNotifierProvider<NutritionNotifier, MealAnalysis?>(
  NutritionNotifier.new,
);
