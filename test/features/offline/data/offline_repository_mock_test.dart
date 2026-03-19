import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/offline/data/repositories/offline_repository_mock.dart';

void main() {
  group('OfflineRepositoryMock', () {
    late OfflineRepositoryMock repository;

    setUp(() {
      repository = OfflineRepositoryMock();
    });

    test('getWeekPlan doit retourner 7 jours', () async {
      final plan = await repository.getWeekPlan('test-user');
      expect(plan.days.length, equals(7));
    });

    test('getWeekPlan en mode offline (par défaut) doit avoir isFromCache à true', () async {
      final plan = await repository.getWeekPlan('test-user');
      expect(plan.isFromCache, isTrue);
    });

    test('getWeekPlan en mode online doit avoir isFromCache à false', () async {
      repository.setOfflineMode(false);
      final plan = await repository.getWeekPlan('test-user');
      expect(plan.isFromCache, isFalse);
    });

    test('hasCachedPlan doit retourner true', () async {
      final has = await repository.hasCachedPlan();
      expect(has, isTrue);
    });

    test('getLastSyncDate doit retourner une date non nulle', () async {
      final date = await repository.getLastSyncDate();
      expect(date, isNotNull);
    });

    test('le premier jour doit être Lundi', () async {
      final plan = await repository.getWeekPlan('test-user');
      expect(plan.days.first.day, equals('Lundi'));
    });

    test('le Mardi doit être un jour de repos', () async {
      final plan = await repository.getWeekPlan('test-user');
      final tuesday = plan.days.firstWhere((d) => d.day == 'Mardi');
      expect(tuesday.isRestDay, isTrue);
    });

    test('le Lundi doit avoir des exercices', () async {
      final plan = await repository.getWeekPlan('test-user');
      final monday = plan.days.firstWhere((d) => d.day == 'Lundi');
      expect(monday.exercises, isNotEmpty);
    });

    test('forceSync doit retourner le même plan que getWeekPlan', () async {
      repository.setOfflineMode(false);
      final planA = await repository.getWeekPlan('test-user');
      final planB = await repository.forceSync('test-user');
      expect(planA.days.length, equals(planB.days.length));
      expect(planA.isFromCache, equals(planB.isFromCache));
    });
  });
}
