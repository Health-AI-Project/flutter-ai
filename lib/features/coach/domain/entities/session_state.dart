import '../../../offline/domain/entities/day_plan.dart';
import '../../../offline/domain/entities/exercise.dart';

enum SessionPhase { exercise, rest, completed }

class SessionState {
  final DayPlan dayPlan;
  final int currentExerciseIndex;
  final SessionPhase phase;
  final int timerSeconds;
  final bool isPaused;

  const SessionState({
    required this.dayPlan,
    required this.currentExerciseIndex,
    required this.phase,
    required this.timerSeconds,
    required this.isPaused,
  });

  Exercise get currentExercise => dayPlan.exercises[currentExerciseIndex];

  bool get isLastExercise =>
      currentExerciseIndex == dayPlan.exercises.length - 1;

  SessionState copyWith({
    int? currentExerciseIndex,
    SessionPhase? phase,
    int? timerSeconds,
    bool? isPaused,
  }) {
    return SessionState(
      dayPlan: dayPlan,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      phase: phase ?? this.phase,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
