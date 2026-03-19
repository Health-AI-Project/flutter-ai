import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../offline/domain/entities/day_plan.dart';
import '../../domain/entities/session_state.dart';
import '../providers/coach_provider.dart';
import '../widgets/exercise_card_widget.dart';
import '../widgets/timer_widget.dart';
import '../widgets/video_demo_widget.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final DayPlan dayPlan;

  const SessionScreen({super.key, required this.dayPlan});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(sessionNotifierProvider.notifier)
          .startSession(widget.dayPlan),
    );
  }

  @override
  void dispose() {
    ref.read(sessionNotifierProvider.notifier).cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session.phase == SessionPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/rpe');
      });
    }

    final exercise = session.currentExercise;
    final total = session.dayPlan.exercises.length;
    final current = session.currentExerciseIndex + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.dayPlan.day} — Exercice $current/$total',
        ),
        actions: [
          if (session.phase == SessionPhase.rest)
            IconButton(
              icon: Icon(
                session.isPaused ? Icons.play_arrow : Icons.pause,
              ),
              onPressed: () =>
                  ref.read(sessionNotifierProvider.notifier).togglePause(),
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: VideoDemoWidget(videoUrl: exercise.videoUrl),
          ),
          ExerciseCardWidget(exercise: exercise),
          if (session.phase == SessionPhase.rest) ...[
            const SizedBox(height: 16),
            TimerWidget(
              timerSeconds: session.timerSeconds,
              totalSeconds: exercise.restSeconds,
            ),
            const SizedBox(height: 8),
            Text(
              session.isPaused ? 'En pause' : 'Repos en cours...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: _buildMainButton(context, session),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, SessionState session) {
    if (session.phase == SessionPhase.rest) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Repos en cours... (${session.timerSeconds}s)',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return FilledButton.icon(
      icon: const Icon(Icons.arrow_forward),
      label: Text(
        session.isLastExercise ? 'Terminer la séance' : 'Exercice suivant →',
      ),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () =>
          ref.read(sessionNotifierProvider.notifier).nextExercise(),
    );
  }
}
