import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/entities/meal_history_item.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

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

final dailyStatsProvider = FutureProvider.autoDispose<DailyStats>((ref) async {
  final response = await DioClient.instance.get(ApiConstants.dailyStats);
  final data = response.data as Map<String, dynamic>;
  return DailyStats(
    calories: (data['calories'] as num?)?.toDouble() ?? 0,
    protein: (data['protein'] as num?)?.toDouble() ?? 0,
    carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
    fat: (data['fat'] as num?)?.toDouble() ?? 0,
    workoutsCount: (data['workouts_count'] as num?)?.toInt() ?? 0,
  );
});

final nutritionHistoryProvider = FutureProvider.autoDispose<List<MealHistoryItem>>((ref) async {
  final response = await DioClient.instance.get(ApiConstants.nutritionHistory);
  final raw = response.data;
  final list = raw is List ? raw : ((raw as Map)['data'] as List? ?? []);
  return list
      .map((e) => MealHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList();
});
