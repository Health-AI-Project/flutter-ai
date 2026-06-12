import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/day_plan.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/week_plan.dart';
import '../../domain/repositories/offline_repository.dart';
import '../models/isar/day_plan_isar.dart';
import '../models/week_plan_model.dart';

class OfflineRepositoryImpl implements OfflineRepository {
  final Dio _dio = DioClient.instance;
  late final Future<Isar> _isarFuture;

  OfflineRepositoryImpl() {
    _isarFuture = _initIsar();
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [DayPlanIsarSchema],
      directory: dir.path,
    );
  }

  @override
  Future<WeekPlan> getWeekPlan(String userId) async {
    try {
      final response = await _dio.get(ApiConstants.weeklyPlan);
      final data = response.data;
      final WeekPlanModel model;
      if (data is List) {
        model = WeekPlanModel.fromBffList(data);
      } else {
        model = WeekPlanModel.fromJson(data as Map<String, dynamic>);
      }
      await _saveToCache(model, userId);
      return model.toEntity();
    } on DioException {
      debugPrint('Offline détecté — fallback cache Isar');
      return _getFromCache(userId);
    }
  }

  Future<void> _saveToCache(WeekPlanModel model, String userId) async {
    final isar = await _isarFuture;
    await isar.writeTxn(() async {
      await isar.dayPlanIsars.filter().userIdEqualTo(userId).deleteAll();
      final isarDays = model.weekPlan
          .map((day) => day.toIsar(userId, model.syncedAt))
          .toList();
      await isar.dayPlanIsars.putAll(isarDays);
    });
    debugPrint('Plan sauvegardé en cache Isar (${model.weekPlan.length} jours)');
  }

  Future<WeekPlan> _getFromCache(String userId) async {
    final Isar isar;
    try {
      isar = await _isarFuture;
    } catch (_) {
      throw Exception('Aucun plan disponible — vérifiez votre connexion');
    }

    final days = await isar.dayPlanIsars
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    if (days.isEmpty) {
      debugPrint('[Coach] Cache Isar vide — fallback plan de démonstration');
      return _demoPlan();
    }

    final syncedAt = days.first.syncedAt;
    return WeekPlan(
      days: days.map(_dayIsarToEntity).toList(),
      syncedAt: syncedAt,
      isFromCache: true,
    );
  }

  DayPlan _dayIsarToEntity(DayPlanIsar isar) {
    return DayPlan(
      day: isar.day,
      sessionType: isar.sessionType,
      durationMinutes: isar.durationMinutes,
      isRestDay: isar.isRestDay,
      exercises: isar.exercises
          .map((e) => Exercise(
                name: e.name,
                sets: e.sets,
                reps: e.reps,
                restSeconds: e.restSeconds,
                videoUrl: e.videoUrl,
                muscleGroup: e.muscleGroup,
              ))
          .toList(),
    );
  }

  WeekPlan _demoPlan() {
    return WeekPlan(
      syncedAt: DateTime.now(),
      isDemo: true,
      days: [
        DayPlan(day: 'Lundi', sessionType: 'Force — Haut du corps', durationMinutes: 45, isRestDay: false, exercises: [
          const Exercise(name: 'Pompes', sets: 4, reps: 12, restSeconds: 60, muscleGroup: 'Pectoraux'),
          const Exercise(name: 'Rowing haltère', sets: 3, reps: 10, restSeconds: 60, muscleGroup: 'Dos'),
          const Exercise(name: 'Développé militaire', sets: 3, reps: 10, restSeconds: 90, muscleGroup: 'Épaules'),
          const Exercise(name: 'Curl biceps', sets: 3, reps: 12, restSeconds: 45, muscleGroup: 'Biceps'),
        ]),
        DayPlan(day: 'Mardi', sessionType: 'Cardio — Endurance', durationMinutes: 30, isRestDay: false, exercises: [
          const Exercise(name: 'Jumping Jacks', sets: 3, reps: 30, restSeconds: 30, muscleGroup: 'Cardio'),
          const Exercise(name: 'Mountain Climbers', sets: 3, reps: 20, restSeconds: 30, muscleGroup: 'Abdominaux'),
          const Exercise(name: 'Burpees', sets: 3, reps: 10, restSeconds: 60, muscleGroup: 'Corps entier'),
        ]),
        DayPlan(day: 'Mercredi', sessionType: 'Repos actif', durationMinutes: 20, isRestDay: true, exercises: [
          const Exercise(name: 'Étirements complets', sets: 1, reps: 1, restSeconds: 0, muscleGroup: 'Corps entier'),
        ]),
        DayPlan(day: 'Jeudi', sessionType: 'Force — Bas du corps', durationMinutes: 50, isRestDay: false, exercises: [
          const Exercise(name: 'Squats', sets: 4, reps: 15, restSeconds: 90, muscleGroup: 'Quadriceps'),
          const Exercise(name: 'Fentes avant', sets: 3, reps: 12, restSeconds: 60, muscleGroup: 'Fessiers'),
          const Exercise(name: 'Soulevé de terre', sets: 3, reps: 8, restSeconds: 120, muscleGroup: 'Ischio-jambiers'),
          const Exercise(name: 'Mollets debout', sets: 3, reps: 20, restSeconds: 45, muscleGroup: 'Mollets'),
        ]),
        DayPlan(day: 'Vendredi', sessionType: 'HIIT — Intensité', durationMinutes: 35, isRestDay: false, exercises: [
          const Exercise(name: 'Sprint sur place', sets: 5, reps: 20, restSeconds: 30, muscleGroup: 'Cardio'),
          const Exercise(name: 'Squat Goblet', sets: 4, reps: 15, restSeconds: 45, muscleGroup: 'Quadriceps'),
          const Exercise(name: 'Planche', sets: 3, reps: 1, restSeconds: 30, muscleGroup: 'Abdominaux'),
        ]),
        DayPlan(day: 'Samedi', sessionType: 'Mobilité & Gainage', durationMinutes: 30, isRestDay: false, exercises: [
          const Exercise(name: 'Dips sur chaise', sets: 3, reps: 12, restSeconds: 60, muscleGroup: 'Triceps'),
          const Exercise(name: 'Superman', sets: 3, reps: 15, restSeconds: 45, muscleGroup: 'Dos'),
          const Exercise(name: 'Crunchs', sets: 3, reps: 20, restSeconds: 30, muscleGroup: 'Abdominaux'),
        ]),
        DayPlan(day: 'Dimanche', sessionType: 'Repos complet', durationMinutes: 0, isRestDay: true, exercises: []),
      ],
    );
  }

  @override
  Future<bool> hasCachedPlan() async {
    final isar = await _isarFuture;
    final count = await isar.dayPlanIsars.count();
    return count > 0;
  }

  @override
  Future<DateTime?> getLastSyncDate() async {
    final isar = await _isarFuture;
    final days = await isar.dayPlanIsars.where().findAll();
    if (days.isEmpty) return null;
    days.sort((a, b) => b.syncedAt.compareTo(a.syncedAt));
    return days.first.syncedAt;
  }

  @override
  Future<WeekPlan> forceSync(String userId) async {
    final response = await _dio.get(ApiConstants.weeklyPlan);
    final data = response.data;
    final WeekPlanModel model;
    if (data is List) {
      model = WeekPlanModel.fromBffList(data);
    } else {
      model = WeekPlanModel.fromJson(data as Map<String, dynamic>);
    }
    await _saveToCache(model, userId);
    return model.toEntity();
  }
}
