import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/coach_provider.dart';
import '../widgets/rpe_slider_widget.dart';

class RpeScreen extends ConsumerStatefulWidget {
  const RpeScreen({super.key});

  @override
  ConsumerState<RpeScreen> createState() => _RpeScreenState();
}

class _RpeScreenState extends ConsumerState<RpeScreen> {
  int _rpe = 5;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);
    final dayLabel = session != null
        ? '${session.dayPlan.day} — ${session.dayPlan.sessionType}'
        : 'Séance terminée';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fin de séance'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Comment s\'est passée la séance ?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              dayLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            RpeSliderWidget(
              value: _rpe,
              onChanged: (v) => setState(() => _rpe = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Valider et terminer'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _sending
                  ? null
                  : () {
                      ref.read(sessionNotifierProvider.notifier).cancelTimer();
                      ref.read(sessionNotifierProvider.notifier);
                      context.go('/week-plan');
                    },
              child: const Text(
                'Passer',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    await ref.read(sessionNotifierProvider.notifier).sendFeedback(_rpe);
    if (mounted) context.go('/week-plan');
  }
}
