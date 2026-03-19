import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/coach/domain/entities/session_state.dart';
import 'package:healthai_coach_mobile/features/coach/presentation/providers/coach_provider.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/day_plan.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/exercise.dart';

void main() {
  const testExercise1 = Exercise(
    name: 'Squat',
    sets: 4,
    reps: 8,
    restSeconds: 5,
    muscleGroup: 'Jambes',
  );

  const testExercise2 = Exercise(
    name: 'Fente',
    sets: 3,
    reps: 12,
    restSeconds: 5,
    muscleGroup: 'Jambes',
  );

  const testDayPlan = DayPlan(
    day: 'Vendredi',
    sessionType: 'Jambes',
    durationMinutes: 60,
    isRestDay: false,
    exercises: [testExercise1, testExercise2],
  );

  group('SessionNotifier', () {
    test('état initial doit être null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(sessionNotifierProvider);
      expect(state, isNull);
    });

    test('startSession doit initialiser l\'état avec le dayPlan', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionNotifierProvider.notifier).startSession(testDayPlan);

      final state = container.read(sessionNotifierProvider);
      expect(state, isNotNull);
      expect(state!.dayPlan.day, equals('Vendredi'));
    });

    test('startSession doit commencer à l\'index 0 en phase exercice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionNotifierProvider.notifier).startSession(testDayPlan);

      final state = container.read(sessionNotifierProvider);
      expect(state!.currentExerciseIndex, equals(0));
      expect(state.phase, equals(SessionPhase.exercise));
    });

    test('togglePause doit mettre la séance en pause', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionNotifierProvider.notifier).startSession(testDayPlan);
      container.read(sessionNotifierProvider.notifier).togglePause();

      final state = container.read(sessionNotifierProvider);
      expect(state!.isPaused, isTrue);
    });

    test('togglePause deux fois doit reprendre la séance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionNotifierProvider.notifier).startSession(testDayPlan);
      container.read(sessionNotifierProvider.notifier).togglePause();
      container.read(sessionNotifierProvider.notifier).togglePause();

      final state = container.read(sessionNotifierProvider);
      expect(state!.isPaused, isFalse);
    });

    test('nextExercise sur le dernier doit terminer la séance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const singleExercisePlan = DayPlan(
        day: 'Lundi',
        sessionType: 'Test',
        durationMinutes: 10,
        isRestDay: false,
        exercises: [testExercise1],
      );

      container.read(sessionNotifierProvider.notifier).startSession(singleExercisePlan);
      container.read(sessionNotifierProvider.notifier).nextExercise();

      final state = container.read(sessionNotifierProvider);
      expect(state!.phase, equals(SessionPhase.completed));
    });
  });
}
