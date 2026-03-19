import '../../domain/entities/day_plan.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/week_plan.dart';
import '../../domain/repositories/offline_repository.dart';

class OfflineRepositoryMock implements OfflineRepository {
  bool _simulateOffline = true;

  void setOfflineMode(bool offline) => _simulateOffline = offline;

  @override
  Future<WeekPlan> getWeekPlan(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_simulateOffline) {
      return WeekPlan(
        days: _mockDays(),
        syncedAt: DateTime.now().subtract(const Duration(hours: 3)),
        isFromCache: true,
      );
    }

    return WeekPlan(
      days: _mockDays(),
      syncedAt: DateTime.now(),
      isFromCache: false,
    );
  }

  List<DayPlan> _mockDays() => [
        const DayPlan(
          day: 'Lundi',
          sessionType: 'Pectoraux / Triceps',
          durationMinutes: 60,
          isRestDay: false,
          exercises: [
            Exercise(name: 'Développé couché', sets: 4, reps: 10, restSeconds: 90, muscleGroup: 'Pectoraux'),
            Exercise(name: 'Écarté poulie', sets: 3, reps: 12, restSeconds: 60, muscleGroup: 'Pectoraux'),
            Exercise(name: 'Dips', sets: 3, reps: 15, restSeconds: 60, muscleGroup: 'Triceps'),
          ],
        ),
        const DayPlan(
          day: 'Mardi',
          sessionType: 'Repos actif',
          durationMinutes: 30,
          isRestDay: true,
          exercises: [],
        ),
        const DayPlan(
          day: 'Mercredi',
          sessionType: 'Dos / Biceps',
          durationMinutes: 65,
          isRestDay: false,
          exercises: [
            Exercise(name: 'Tractions', sets: 4, reps: 8, restSeconds: 120, muscleGroup: 'Dos'),
            Exercise(name: 'Rowing barre', sets: 3, reps: 10, restSeconds: 90, muscleGroup: 'Dos'),
            Exercise(name: 'Curl biceps', sets: 3, reps: 12, restSeconds: 60, muscleGroup: 'Biceps'),
          ],
        ),
        const DayPlan(
          day: 'Jeudi',
          sessionType: 'Repos',
          durationMinutes: 0,
          isRestDay: true,
          exercises: [],
        ),
        const DayPlan(
          day: 'Vendredi',
          sessionType: 'Jambes',
          durationMinutes: 70,
          isRestDay: false,
          exercises: [
            Exercise(name: 'Squat', sets: 4, reps: 8, restSeconds: 120, muscleGroup: 'Quadriceps'),
            Exercise(name: 'Presse à cuisses', sets: 3, reps: 12, restSeconds: 90, muscleGroup: 'Quadriceps'),
            Exercise(name: 'Soulevé de terre roumain', sets: 3, reps: 10, restSeconds: 90, muscleGroup: 'Ischio-jambiers'),
          ],
        ),
        const DayPlan(
          day: 'Samedi',
          sessionType: 'Cardio',
          durationMinutes: 40,
          isRestDay: false,
          exercises: [
            Exercise(name: 'Course à pied', sets: 1, reps: 1, restSeconds: 0, muscleGroup: 'Cardio'),
          ],
        ),
        const DayPlan(
          day: 'Dimanche',
          sessionType: 'Repos',
          durationMinutes: 0,
          isRestDay: true,
          exercises: [],
        ),
      ];

  @override
  Future<bool> hasCachedPlan() async => true;

  @override
  Future<DateTime?> getLastSyncDate() async =>
      DateTime.now().subtract(const Duration(hours: 3));

  @override
  Future<WeekPlan> forceSync(String userId) => getWeekPlan(userId);
}
