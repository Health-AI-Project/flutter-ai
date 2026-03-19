import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/day_plan.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/exercise.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/week_plan.dart';

void main() {
  const exercice = Exercise(
    name: 'Squat',
    sets: 4,
    reps: 8,
    restSeconds: 90,
    muscleGroup: 'Jambes',
  );

  const lundiPlan = DayPlan(
    day: 'Lundi',
    sessionType: 'Jambes',
    durationMinutes: 60,
    isRestDay: false,
    exercises: [exercice],
  );

  const mardiRepos = DayPlan(
    day: 'Mardi',
    sessionType: 'Repos',
    durationMinutes: 0,
    isRestDay: true,
    exercises: [],
  );

  group('Exercise', () {
    test('doit avoir un nom non vide', () {
      expect(exercice.name, isNotEmpty);
    });

    test('sets doit être positif', () {
      expect(exercice.sets, greaterThan(0));
    });

    test('reps doit être positif', () {
      expect(exercice.reps, greaterThan(0));
    });

    test('videoUrl doit être null par défaut', () {
      expect(exercice.videoUrl, isNull);
    });
  });

  group('DayPlan', () {
    test('un jour de repos ne doit pas avoir d\'exercices', () {
      expect(mardiRepos.isRestDay, isTrue);
      expect(mardiRepos.exercises, isEmpty);
    });

    test('un jour actif doit avoir des exercices', () {
      expect(lundiPlan.isRestDay, isFalse);
      expect(lundiPlan.exercises, isNotEmpty);
    });

    test('durationMinutes doit être 0 pour un jour de repos', () {
      expect(mardiRepos.durationMinutes, equals(0));
    });

    test('le nom du jour doit être correct', () {
      expect(lundiPlan.day, equals('Lundi'));
    });
  });

  group('WeekPlan', () {
    test('doit contenir 2 jours', () {
      final plan = WeekPlan(
        days: [lundiPlan, mardiRepos],
        syncedAt: DateTime(2026, 3, 19),
      );
      expect(plan.days.length, equals(2));
    });

    test('isFromCache doit être false par défaut', () {
      final plan = WeekPlan(
        days: [lundiPlan],
        syncedAt: DateTime(2026, 3, 19),
      );
      expect(plan.isFromCache, isFalse);
    });

    test('isFromCache peut être true', () {
      final plan = WeekPlan(
        days: [lundiPlan],
        syncedAt: DateTime(2026, 3, 19),
        isFromCache: true,
      );
      expect(plan.isFromCache, isTrue);
    });

    test('syncedAt doit être conservé', () {
      final date = DateTime(2026, 3, 19, 10, 0);
      final plan = WeekPlan(
        days: [],
        syncedAt: date,
      );
      expect(plan.syncedAt, equals(date));
    });
  });
}
