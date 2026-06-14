import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/nutrition_local_storage.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/entities/meal_history_item.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../data/repositories/nutrition_repository_impl.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepositoryImpl(),
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

/// État du suivi nutritionnel du jour : totaux + historique des repas,
/// reconstruits à partir du journal local (persisté en SharedPreferences).
class NutritionDailyState {
  final DailyStats stats;
  final List<MealHistoryItem> history;

  const NutritionDailyState({required this.stats, required this.history});
}

class NutritionDailyNotifier extends AsyncNotifier<NutritionDailyState> {
  final _storage = NutritionLocalStorage();

  @override
  Future<NutritionDailyState> build() async {
    final history = await _storage.loadTodayHistory();
    return NutritionDailyState(stats: _computeStats(history), history: history);
  }

  /// Ajoute un repas (issu d'une analyse photo ou d'une saisie manuelle)
  /// au journal du jour et met à jour les totaux affichés sur le hub.
  Future<void> addMeal(MealAnalysis analysis, {String? imageUrl}) async {
    final current = state.valueOrNull ??
        const NutritionDailyState(stats: DailyStats.empty, history: []);

    final now = DateTime.now();
    final item = MealHistoryItem(
      id: now.microsecondsSinceEpoch.toString(),
      date: _formatTime(now),
      imageUrl: imageUrl,
      calories: analysis.totalCalories,
      protein: analysis.totalProteins,
      carbs: analysis.totalCarbs,
      fat: analysis.totalFats,
    );

    final updatedHistory = [item, ...current.history];
    await _storage.saveTodayHistory(updatedHistory);
    state = AsyncData(
      NutritionDailyState(stats: _computeStats(updatedHistory), history: updatedHistory),
    );
  }

  DailyStats _computeStats(List<MealHistoryItem> history) {
    var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0;
    for (final meal in history) {
      calories += meal.calories;
      protein += meal.protein;
      carbs += meal.carbs;
      fat += meal.fat;
    }
    return DailyStats(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      workoutsCount: 0,
    );
  }

  String _formatTime(DateTime d) =>
      "Aujourd'hui ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
}

final nutritionDailyProvider =
    AsyncNotifierProvider<NutritionDailyNotifier, NutritionDailyState>(
  NutritionDailyNotifier.new,
);
