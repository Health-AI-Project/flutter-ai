import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../offline/domain/entities/day_plan.dart';
import '../../../offline/presentation/providers/offline_provider.dart';

class CoachHubScreen extends ConsumerStatefulWidget {
  const CoachHubScreen({super.key});

  @override
  ConsumerState<CoachHubScreen> createState() => _CoachHubScreenState();
}

class _CoachHubScreenState extends ConsumerState<CoachHubScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _userId = await TokenStorage.getUserId() ?? 'guest';
      if (mounted) {
        ref.read(weekPlanNotifierProvider.notifier).loadPlan(_userId!);
      }
    });
  }

  // Retourne l'index du jour courant dans le plan (lundi=0 … dimanche=6)
  int _todayIndex(List<DayPlan> days) {
    final weekday = DateTime.now().weekday; // 1=lundi, 7=dimanche
    final idx = weekday - 1;
    return idx.clamp(0, days.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(weekPlanNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Coach',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref
                .read(weekPlanNotifierProvider.notifier)
                .forceSync(_userId ?? 'guest'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push('/week-plan'),
          ),
        ],
      ),
      body: planState.when(
        data: (plan) {
          if (plan == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final todayIdx = _todayIndex(plan.days);
          final today = plan.days[todayIdx];
          final previewDays = plan.days.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (plan.isDemo)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Aperçu de démonstration — le service coach est en cours de déploiement.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildTodaySession(context, today),
                const SizedBox(height: 16),
                _buildWeekStats(plan.days),
                const SizedBox(height: 24),
                _buildWeekPreview(context, previewDays),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => ErrorStateWidget(
          error: e,
          context: 'CoachPlan',
          icon: Icons.fitness_center_outlined,
          onRetry: () => ref
              .read(weekPlanNotifierProvider.notifier)
              .loadPlan(_userId ?? 'guest'),
        ),
      ),
    );
  }

  Widget _buildTodaySession(BuildContext context, DayPlan today) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SÉANCE DU JOUR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.08,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: today.isRestDay
                      ? AppColors.surfaceAlt
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  today.isRestDay
                      ? Icons.bedtime_outlined
                      : Icons.fitness_center,
                  color: today.isRestDay
                      ? AppColors.textTertiary
                      : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today.sessionType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          today.isRestDay
                              ? 'Repos'
                              : '${today.durationMinutes} min',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (!today.isRestDay) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'À faire',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!today.isRestDay) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => context.push('/session', extra: today),
              child: const Text('Démarrer la séance →'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekStats(List<DayPlan> days) {
    final todayIdx = _todayIndex(days);
    final total = days.where((d) => !d.isRestDay).length;
    final doneThisWeek = days
        .asMap()
        .entries
        .where((e) => e.key <= todayIdx && !e.value.isRestDay)
        .length;
    final totalExercises = days
        .where((d) => !d.isRestDay)
        .fold<int>(0, (sum, d) => sum + d.exercises.length);
    return Row(
      children: [
        _StatCard(value: '$doneThisWeek / $total', label: 'séances'),
        const SizedBox(width: 10),
        _StatCard(value: '$totalExercises', label: 'exercices prévus'),
        const SizedBox(width: 10),
        _StatCard(value: '🔥 $doneThisWeek', label: 'jours actifs'),
      ],
    );
  }

  Widget _buildWeekPreview(BuildContext context, List<DayPlan> days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PLANNING SEMAINE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.08,
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/week-plan'),
              child: const Text(
                'Voir tout →',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: days.asMap().entries.map((entry) {
              final i = entry.key;
              final day = entry.value;
              final isLast = i == days.length - 1;
              return Column(
                children: [
                  _DayPreviewRow(
                    dayPlan: day,
                    isToday: i == _todayIndex(days),
                    onTap: day.isRestDay
                        ? null
                        : () => context.push('/session', extra: day),
                  ),
                  if (!isLast) const Divider(height: 0.5, indent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPreviewRow extends StatelessWidget {
  final DayPlan dayPlan;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayPreviewRow({
    required this.dayPlan,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dayPlan.isRestDay ? 0.5 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: isToday
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dayPlan.isRestDay
                      ? AppColors.surfaceAlt
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  dayPlan.isRestDay
                      ? Icons.bedtime_outlined
                      : Icons.fitness_center_outlined,
                  size: 14,
                  color: dayPlan.isRestDay
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayPlan.day,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      dayPlan.sessionType,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Aujourd\'hui',
                    style: TextStyle(fontSize: 10, color: AppColors.primary),
                  ),
                )
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dayPlan.isRestDay
                        ? AppColors.textTertiary
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
