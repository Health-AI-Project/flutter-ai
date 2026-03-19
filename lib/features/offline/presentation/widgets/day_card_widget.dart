import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/day_plan.dart';

class DayCardWidget extends StatelessWidget {
  final DayPlan dayPlan;

  const DayCardWidget({super.key, required this.dayPlan});

  Color _muscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'pectoraux':
        return Colors.blue;
      case 'triceps':
        return Colors.indigo;
      case 'dos':
        return Colors.green;
      case 'biceps':
        return Colors.teal;
      case 'quadriceps':
      case 'ischio-jambiers':
      case 'jambes':
        return Colors.orange;
      case 'cardio':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dayPlan.isRestDay) {
      return _RestDayCard(day: dayPlan.day, sessionType: dayPlan.sessionType);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: dayPlan.isRestDay
            ? null
            : () => context.push('/session', extra: dayPlan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayPlan.day,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          dayPlan.sessionType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text('${dayPlan.durationMinutes} min'),
                    avatar: const Icon(Icons.timer, size: 16),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...dayPlan.exercises.map(
                (exercise) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${exercise.sets} x ${exercise.reps}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      _MuscleGroupBadge(
                        label: exercise.muscleGroup,
                        color: _muscleGroupColor(exercise.muscleGroup),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  final String day;
  final String sessionType;

  const _RestDayCard({required this.day, required this.sessionType});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bedtime, color: Colors.grey, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  sessionType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleGroupBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MuscleGroupBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
