import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/nutrition/domain/entities/meal_analysis.dart';

void main() {
  group('MealAnalysis', () {
    const food1 = FoodItem(
      name: 'Riz',
      calories: 200,
      proteins: 4,
      carbs: 45,
      fats: 0.5,
    );

    const food2 = FoodItem(
      name: 'Poulet',
      calories: 165,
      proteins: 31,
      carbs: 0,
      fats: 3.6,
    );

    const meal = MealAnalysis(
      foods: [food1, food2],
      totalCalories: 365,
      totalProteins: 35,
      totalCarbs: 45,
      totalFats: 4.1,
      suggestions: ['Bon équilibre protéique'],
    );

    test('doit contenir 2 aliments', () {
      expect(meal.foods.length, equals(2));
    });

    test('totalCalories doit être 365', () {
      expect(meal.totalCalories, equals(365));
    });

    test('copyWith doit modifier uniquement les champs spécifiés', () {
      final modified = meal.copyWith(totalCalories: 500);
      expect(modified.totalCalories, equals(500));
      expect(modified.foods.length, equals(2));
    });

    test('suggestions ne doit pas être vide', () {
      expect(meal.suggestions, isNotEmpty);
    });

    test('copyWith sans argument doit retourner un objet identique', () {
      final copy = meal.copyWith();
      expect(copy.totalCalories, equals(meal.totalCalories));
      expect(copy.foods.length, equals(meal.foods.length));
      expect(copy.suggestions, equals(meal.suggestions));
    });
  });

  group('FoodItem', () {
    test('doit avoir un nom non vide', () {
      const food = FoodItem(
        name: 'Test',
        calories: 100,
        proteins: 5,
        carbs: 20,
        fats: 1,
      );
      expect(food.name, isNotEmpty);
    });

    test('calories doit être positif', () {
      const food = FoodItem(
        name: 'Test',
        calories: 100,
        proteins: 5,
        carbs: 20,
        fats: 1,
      );
      expect(food.calories, greaterThan(0));
    });

    test('copyWith doit modifier uniquement le nom', () {
      const food = FoodItem(
        name: 'Ancien',
        calories: 100,
        proteins: 5,
        carbs: 20,
        fats: 1,
      );
      final modified = food.copyWith(name: 'Nouveau');
      expect(modified.name, equals('Nouveau'));
      expect(modified.calories, equals(100));
    });
  });
}
