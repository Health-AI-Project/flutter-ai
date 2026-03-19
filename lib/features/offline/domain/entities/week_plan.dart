import 'day_plan.dart';

class WeekPlan {
  final List<DayPlan> days;
  final DateTime syncedAt;
  final bool isFromCache;

  const WeekPlan({
    required this.days,
    required this.syncedAt,
    this.isFromCache = false,
  });
}
