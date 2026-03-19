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
      final response = await _dio.get(
        '${ApiConstants.weeklyPlan}?userId=$userId',
      );
      final model = WeekPlanModel.fromJson(response.data as Map<String, dynamic>);
      await _saveToCache(model, userId);
      return model.toEntity();
    } on DioException {
      debugPrint('Offline détecté — lecture cache Isar');
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
      throw Exception('Aucun plan disponible — vérifiez votre connexion');
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
    final response = await _dio.get(
      '${ApiConstants.weeklyPlan}?userId=$userId',
    );
    final model = WeekPlanModel.fromJson(response.data as Map<String, dynamic>);
    await _saveToCache(model, userId);
    return model.toEntity();
  }
}
