import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
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

  Color get _rpeColor {
    if (_rpe <= 3) return AppColors.primary;
    if (_rpe <= 7) return AppColors.accent;
    return const Color(0xFFE07B5F);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);
    final dayLabel = session != null
        ? '${session.dayPlan.day} — ${session.dayPlan.sessionType}'
        : 'Séance terminée';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fin de séance'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Comment s\'est passée la séance ?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabel,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_rpe / 10',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: _rpeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rpeLabel(_rpe),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        RpeSliderWidget(
                          value: _rpe,
                          onChanged: (v) => setState(() => _rpe = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Text('Valider et terminer'),
              ),
            ),
          ),
          TextButton(
            onPressed: _sending
                ? null
                : () {
                    ref.read(sessionNotifierProvider.notifier).cancelTimer();
                    context.go('/home');
                  },
            child: const Text(
              'Passer',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _rpeLabel(int rpe) {
    if (rpe <= 2) return 'Très facile';
    if (rpe <= 4) return 'Facile';
    if (rpe <= 6) return 'Modéré';
    if (rpe <= 8) return 'Difficile';
    return 'Très difficile';
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    await ref.read(sessionNotifierProvider.notifier).sendFeedback(_rpe);
    if (mounted) context.go('/home');
  }
}
