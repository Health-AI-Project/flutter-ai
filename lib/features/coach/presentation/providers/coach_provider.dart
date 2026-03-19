import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../offline/domain/entities/day_plan.dart';
import '../../data/repositories/coach_repository_mock.dart';
import '../../domain/entities/session_feedback.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/coach_repository.dart';

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => CoachRepositoryMock(), // TODO: remplacer par CoachRepositoryImpl()
);

final currentDayPlanProvider = StateProvider<DayPlan?>((ref) => null);

final sessionNotifierProvider =
    NotifierProvider<SessionNotifier, SessionState?>(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState?> {
  Timer? _timer;

  @override
  SessionState? build() => null;

  void startSession(DayPlan dayPlan) {
    _timer?.cancel();
    state = SessionState(
      dayPlan: dayPlan,
      currentExerciseIndex: 0,
      phase: SessionPhase.exercise,
      timerSeconds: dayPlan.exercises.first.restSeconds,
      isPaused: false,
    );
  }

  void startRestTimer() {
    final current = state;
    if (current == null) return;

    state = current.copyWith(
      phase: SessionPhase.rest,
      timerSeconds: current.currentExercise.restSeconds,
      isPaused: false,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      if (current == null || current.isPaused) return;

      if (current.timerSeconds <= 1) {
        timer.cancel();
        _onTimerFinished();
      } else {
        state = current.copyWith(timerSeconds: current.timerSeconds - 1);
      }
    });
  }

  void _onTimerFinished() {
    final current = state;
    if (current == null) return;

    if (current.isLastExercise) {
      state = current.copyWith(phase: SessionPhase.completed);
    } else {
      state = current.copyWith(
        phase: SessionPhase.exercise,
        currentExerciseIndex: current.currentExerciseIndex + 1,
      );
    }
  }

  void nextExercise() {
    final current = state;
    if (current == null) return;
    _timer?.cancel();

    if (current.isLastExercise) {
      state = current.copyWith(phase: SessionPhase.completed);
    } else {
      startRestTimer();
    }
  }

  void togglePause() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(isPaused: !current.isPaused);
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  Future<void> sendFeedback(int rpe) async {
    final current = state;
    if (current == null) return;

    final feedback = SessionFeedback(
      userId: 'test-user-001',
      sessionDay: current.dayPlan.day,
      rpe: rpe,
      completedAt: DateTime.now(),
    );

    final success =
        await ref.read(coachRepositoryProvider).sendFeedback(feedback);
    debugPrint('Feedback envoyé : $success');
    state = null;
  }
}
