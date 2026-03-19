import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/offline/domain/entities/day_plan.dart';
import '../../features/offline/domain/entities/exercise.dart';

class DevHomeScreen extends StatelessWidget {
  const DevHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HealthAI Coach — Dev')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mode Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tester Feature A — Caméra'),
              onPressed: () => context.push('/camera'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: const Text('Tester Feature C — Planning semaine'),
              onPressed: () => context.push('/week-plan'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle),
              label: const Text('Tester Feature B — Séance Lundi'),
              onPressed: () {
                const mockDayPlan = DayPlan(
                  day: 'Lundi',
                  sessionType: 'Pectoraux / Triceps',
                  durationMinutes: 60,
                  isRestDay: false,
                  exercises: [
                    Exercise(
                      name: 'Développé couché',
                      sets: 4,
                      reps: 10,
                      restSeconds: 10,
                      muscleGroup: 'Pectoraux',
                    ),
                    Exercise(
                      name: 'Écarté poulie',
                      sets: 3,
                      reps: 12,
                      restSeconds: 8,
                      muscleGroup: 'Pectoraux',
                    ),
                    Exercise(
                      name: 'Dips',
                      sets: 3,
                      reps: 15,
                      restSeconds: 6,
                      muscleGroup: 'Triceps',
                    ),
                  ],
                );
                context.push('/session', extra: mockDayPlan);
              },
            ),
          ],
        ),
      ),
    );
  }
}
