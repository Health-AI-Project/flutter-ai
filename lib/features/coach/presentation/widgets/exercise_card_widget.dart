import 'package:flutter/material.dart';

import '../../../offline/domain/entities/exercise.dart';

class ExerciseCardWidget extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCardWidget({super.key, required this.exercise});

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
    final color = _muscleGroupColor(exercise.muscleGroup);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${exercise.sets} séries × ${exercise.reps} répétitions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    exercise.muscleGroup,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Repos : ${exercise.restSeconds}s après cet exercice',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
