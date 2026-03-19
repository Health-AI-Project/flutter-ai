import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/nutrition/data/repositories/nutrition_repository_mock.dart';
import 'package:healthai_coach_mobile/features/nutrition/presentation/providers/nutrition_provider.dart';

void main() {
  group('NutritionProvider', () {
    test('état initial doit être null', () {
      final container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(
            NutritionRepositoryMock(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(nutritionProvider);
      expect(state.value, isNull);
    });

    test('analyzeMeal doit retourner des données après appel', () async {
      final container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(
            NutritionRepositoryMock(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(nutritionProvider.notifier)
          .analyzeMeal('test.jpg', 'user-1');

      final state = container.read(nutritionProvider);
      expect(state.value, isNotNull);
      expect(state.value!.foods, isNotEmpty);
    });

    test('totalCalories doit être positif après analyse', () async {
      final container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(
            NutritionRepositoryMock(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(nutritionProvider.notifier)
          .analyzeMeal('test.jpg', 'user-1');

      final state = container.read(nutritionProvider);
      expect(state.value!.totalCalories, greaterThan(0));
    });

    test('reset() doit remettre l\'état à null', () async {
      final container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(
            NutritionRepositoryMock(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(nutritionProvider.notifier)
          .analyzeMeal('test.jpg', 'user-1');

      container.read(nutritionProvider.notifier).reset();

      final state = container.read(nutritionProvider);
      expect(state.value, isNull);
    });

    test('suggestions doit contenir au moins un élément après analyse', () async {
      final container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(
            NutritionRepositoryMock(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(nutritionProvider.notifier)
          .analyzeMeal('test.jpg', 'user-1');

      final state = container.read(nutritionProvider);
      expect(state.value!.suggestions, isNotEmpty);
    });
  });
}
