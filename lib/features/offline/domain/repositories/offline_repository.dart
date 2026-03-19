import '../entities/week_plan.dart';

abstract class OfflineRepository {
  Future<WeekPlan> getWeekPlan(String userId);
  Future<bool> hasCachedPlan();
  Future<DateTime?> getLastSyncDate();
  Future<WeekPlan> forceSync(String userId);
}
