import '../../domain/entities/exercise.dart';
import '../../domain/entities/day_plan.dart';
import '../../domain/entities/week_plan.dart';
import 'isar/exercise_isar.dart';
import 'isar/day_plan_isar.dart';

class ExerciseModel {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? videoUrl;
  final String muscleGroup;

  const ExerciseModel({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.videoUrl,
    required this.muscleGroup,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'] as String? ?? '',
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      restSeconds: json['restSeconds'] as int? ?? 0,
      videoUrl: json['videoUrl'] as String?,
      muscleGroup: json['muscleGroup'] as String? ?? '',
    );
  }

  Exercise toEntity() {
    return Exercise(
      name: name,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      videoUrl: videoUrl,
      muscleGroup: muscleGroup,
    );
  }

  ExerciseIsar toIsar() {
    return ExerciseIsar()
      ..name = name
      ..sets = sets
      ..reps = reps
      ..restSeconds = restSeconds
      ..videoUrl = videoUrl
      ..muscleGroup = muscleGroup;
  }
}

class DayPlanModel {
  final String day;
  final String sessionType;
  final List<ExerciseModel> exercises;
  final int durationMinutes;
  final bool isRestDay;

  const DayPlanModel({
    required this.day,
    required this.sessionType,
    required this.exercises,
    required this.durationMinutes,
    required this.isRestDay,
  });

  factory DayPlanModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    return DayPlanModel(
      day: json['day'] as String? ?? '',
      sessionType: json['sessionType'] as String? ?? '',
      exercises: rawExercises
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      isRestDay: json['isRestDay'] as bool? ?? false,
    );
  }

  DayPlan toEntity() {
    return DayPlan(
      day: day,
      sessionType: sessionType,
      exercises: exercises.map((e) => e.toEntity()).toList(),
      durationMinutes: durationMinutes,
      isRestDay: isRestDay,
    );
  }

  DayPlanIsar toIsar(String userId, DateTime syncedAt) {
    return DayPlanIsar()
      ..day = day
      ..sessionType = sessionType
      ..exercises = exercises.map((e) => e.toIsar()).toList()
      ..durationMinutes = durationMinutes
      ..isRestDay = isRestDay
      ..syncedAt = syncedAt
      ..userId = userId;
  }
}

class WeekPlanModel {
  final List<DayPlanModel> weekPlan;
  final DateTime syncedAt;

  const WeekPlanModel({
    required this.weekPlan,
    required this.syncedAt,
  });

  factory WeekPlanModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['weekPlan'] as List<dynamic>? ?? [];
    return WeekPlanModel(
      weekPlan: rawDays
          .map((d) => DayPlanModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : DateTime.now(),
    );
  }

  WeekPlan toEntity() {
    return WeekPlan(
      days: weekPlan.map((d) => d.toEntity()).toList(),
      syncedAt: syncedAt,
      isFromCache: false,
    );
  }
}
