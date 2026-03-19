import 'exercise.dart';

class DayPlan {
  final String day;
  final String sessionType;
  final List<Exercise> exercises;
  final int durationMinutes;
  final bool isRestDay;

  const DayPlan({
    required this.day,
    required this.sessionType,
    required this.exercises,
    required this.durationMinutes,
    required this.isRestDay,
  });
}
