import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
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
  SessionNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _notifier = ref.read(sessionNotifierProvider.notifier);
      _notifier!.startSession(widget.dayPlan);
    });
  }

  @override
  void dispose() {
    _notifier?.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);

    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.dayPlan.day} — $current / $total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: AppColors.surfaceAlt,
            color: AppColors.primary,
            minHeight: 3,
          ),
        ),
        actions: [
          if (session.phase == SessionPhase.rest)
            IconButton(
              icon: Icon(
                session.isPaused ? Icons.play_arrow : Icons.pause,
                color: AppColors.primary,
              ),
              onPressed: () =>
                  ref.read(sessionNotifierProvider.notifier).togglePause(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            color: AppColors.surfaceAlt,
            child: VideoDemoWidget(videoUrl: exercise.videoUrl),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  ExerciseCardWidget(exercise: exercise),
                  if (session.phase == SessionPhase.rest) ...[
                    const SizedBox(height: 16),
                    TimerWidget(
                      timerSeconds: session.timerSeconds,
                      totalSeconds: exercise.restSeconds,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.isPaused ? 'En pause' : 'Repos en cours…',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: _buildMainButton(session),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(SessionState session) {
    if (session.phase == SessionPhase.rest) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceAlt,
          foregroundColor: AppColors.textTertiary,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          minimumSize: const Size(double.infinity, 44),
        ),
        child: Text('Repos en cours… (${session.timerSeconds}s)'),
      );
    }

    return ElevatedButton(
      onPressed: () =>
          ref.read(sessionNotifierProvider.notifier).nextExercise(),
      child: Text(
        session.isLastExercise ? 'Terminer la séance' : 'Exercice suivant →',
      ),
    );
  }
}
