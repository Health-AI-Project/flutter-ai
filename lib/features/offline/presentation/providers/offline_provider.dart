import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/offline_repository_mock.dart';
import '../../domain/entities/week_plan.dart';
import '../../domain/repositories/offline_repository.dart';

final offlineRepositoryProvider = Provider<OfflineRepository>(
  (ref) => OfflineRepositoryMock(), // TODO: remplacer par OfflineRepositoryImpl()
);

final weekPlanNotifierProvider =
    AsyncNotifierProvider<WeekPlanNotifier, WeekPlan?>(
  WeekPlanNotifier.new,
);

class WeekPlanNotifier extends AsyncNotifier<WeekPlan?> {
  @override
  Future<WeekPlan?> build() async => null;

  Future<void> loadPlan(String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineRepositoryProvider).getWeekPlan(userId),
    );
  }

  Future<void> forceSync(String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineRepositoryProvider).forceSync(userId),
    );
  }
}
