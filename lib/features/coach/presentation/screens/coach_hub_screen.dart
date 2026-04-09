import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../offline/domain/entities/day_plan.dart';
import '../../../offline/domain/entities/exercise.dart';

const _mockWeek = [
  DayPlan(
    day: 'Lundi',
    sessionType: 'Pectoraux / Triceps',
    durationMinutes: 60,
    isRestDay: false,
    exercises: [
      Exercise(name: 'Développé couché', sets: 4, reps: 10, restSeconds: 10, muscleGroup: 'Pectoraux'),
      Exercise(name: 'Écarté poulie', sets: 3, reps: 12, restSeconds: 8, muscleGroup: 'Pectoraux'),
      Exercise(name: 'Dips', sets: 3, reps: 15, restSeconds: 6, muscleGroup: 'Triceps'),
    ],
  ),
  DayPlan(
    day: 'Mardi',
    sessionType: 'Repos actif',
    durationMinutes: 0,
    isRestDay: true,
    exercises: [],
  ),
  DayPlan(
    day: 'Mercredi',
    sessionType: 'Dos / Biceps',
    durationMinutes: 65,
    isRestDay: false,
    exercises: [
      Exercise(name: 'Tractions', sets: 4, reps: 8, restSeconds: 12, muscleGroup: 'Dos'),
      Exercise(name: 'Rowing barre', sets: 3, reps: 10, restSeconds: 9, muscleGroup: 'Dos'),
    ],
  ),
];

class CoachHubScreen extends StatelessWidget {
  const CoachHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Coach',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () {}),
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTodaySession(context),
            const SizedBox(height: 16),
            _buildWeekStats(),
            const SizedBox(height: 24),
            _buildWeekPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySession(BuildContext context) {
    final today = _mockWeek.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(blurRadius: 3, color: Color(0x10000000)),
        ],
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
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
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${today.durationMinutes} min',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
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
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.push('/session', extra: today),
            child: const Text('Démarrer la séance →'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStats() {
    return Row(
      children: [
        _StatCard(value: '3 / 5', label: 'séances'),
        const SizedBox(width: 10),
        _StatCard(value: '1 240', label: 'kcal brûlées'),
        const SizedBox(width: 10),
        _StatCard(value: '🔥 5', label: 'jours streak'),
      ],
    );
  }

  Widget _buildWeekPreview(BuildContext context) {
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
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: _mockWeek.asMap().entries.map((entry) {
              final i = entry.key;
              final day = entry.value;
              final isLast = i == _mockWeek.length - 1;
              return Column(
                children: [
                  _DayPreviewRow(
                    dayPlan: day,
                    isToday: i == 0,
                    onTap: day.isRestDay ? null : () => context.push('/session', extra: day),
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
          border: Border.all(color: AppColors.border, width: 0.5),
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
          color: isToday ? AppColors.primaryLight.withValues(alpha: 0.4) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dayPlan.isRestDay ? AppColors.surfaceAlt : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  dayPlan.isRestDay ? Icons.bedtime_outlined : Icons.fitness_center_outlined,
                  size: 14,
                  color: dayPlan.isRestDay ? AppColors.textTertiary : AppColors.primary,
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
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dayPlan.isRestDay ? AppColors.textTertiary : AppColors.primary,
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
