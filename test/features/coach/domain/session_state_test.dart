import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/coach/domain/entities/session_state.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/day_plan.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/exercise.dart';

void main() {
  const exercise1 = Exercise(
    name: 'Développé couché',
    sets: 4,
    reps: 10,
    restSeconds: 90,
    muscleGroup: 'Pectoraux',
  );

  const exercise2 = Exercise(
    name: 'Écarté poulie',
    sets: 3,
    reps: 12,
    restSeconds: 60,
    muscleGroup: 'Pectoraux',
  );

  const dayPlan = DayPlan(
    day: 'Lundi',
    sessionType: 'Pectoraux',
    durationMinutes: 60,
    isRestDay: false,
    exercises: [exercise1, exercise2],
  );

  group('SessionState', () {
    test('currentExercise doit retourner le premier exercice', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 0,
        phase: SessionPhase.exercise,
        timerSeconds: 90,
        isPaused: false,
      );
      expect(state.currentExercise.name, equals('Développé couché'));
    });

    test('isLastExercise doit être false sur le premier exercice', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 0,
        phase: SessionPhase.exercise,
        timerSeconds: 90,
        isPaused: false,
      );
      expect(state.isLastExercise, isFalse);
    });

    test('isLastExercise doit être true sur le dernier exercice', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 1,
        phase: SessionPhase.exercise,
        timerSeconds: 60,
        isPaused: false,
      );
      expect(state.isLastExercise, isTrue);
    });

    test('copyWith doit modifier uniquement isPaused', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 0,
        phase: SessionPhase.exercise,
        timerSeconds: 90,
        isPaused: false,
      );
      final paused = state.copyWith(isPaused: true);
      expect(paused.isPaused, isTrue);
      expect(paused.currentExerciseIndex, equals(0));
    });

    test('copyWith phase doit changer la phase en repos', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 0,
        phase: SessionPhase.exercise,
        timerSeconds: 90,
        isPaused: false,
      );
      final resting = state.copyWith(phase: SessionPhase.rest);
      expect(resting.phase, equals(SessionPhase.rest));
    });

    test('currentExercise doit retourner le second exercice à l\'index 1', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 1,
        phase: SessionPhase.exercise,
        timerSeconds: 60,
        isPaused: false,
      );
      expect(state.currentExercise.name, equals('Écarté poulie'));
    });

    test('copyWith timerSeconds doit mettre à jour le timer', () {
      final state = SessionState(
        dayPlan: dayPlan,
        currentExerciseIndex: 0,
        phase: SessionPhase.rest,
        timerSeconds: 90,
        isPaused: false,
      );
      final updated = state.copyWith(timerSeconds: 45);
      expect(updated.timerSeconds, equals(45));
      expect(updated.phase, equals(SessionPhase.rest));
    });
  });
}
