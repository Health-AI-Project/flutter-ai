import 'package:isar/isar.dart';
import 'exercise_isar.dart';

part 'day_plan_isar.g.dart';

@collection
class DayPlanIsar {
  Id id = Isar.autoIncrement;

  late String day;
  late String sessionType;
  late List<ExerciseIsar> exercises;
  late int durationMinutes;
  late bool isRestDay;
  late DateTime syncedAt;

  @Index()
  late String userId;
}
