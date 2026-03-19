import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/nutrition/data/models/meal_analysis_model.dart';

void main() {
  group('MealAnalysisModel.fromJson', () {
    test('doit parser un JSON valide correctement', () {
      final json = {
        'foods': [
          {
            'name': 'Riz',
            'calories': 200.0,
            'proteins': 4.0,
            'carbs': 45.0,
            'fats': 0.5,
          }
        ],
        'totalCalories': 200.0,
        'totalProteins': 4.0,
        'totalCarbs': 45.0,
        'totalFats': 0.5,
        'suggestions': ['Bien'],
      };

      final model = MealAnalysisModel.fromJson(json);
      expect(model.foods.length, equals(1));
      expect(model.totalCalories, equals(200.0));
    });

    test('doit gérer les valeurs nulles avec des défauts à 0', () {
      final json = {
        'foods': [],
        'totalCalories': null,
        'totalProteins': null,
        'totalCarbs': null,
        'totalFats': null,
        'suggestions': [],
      };

      final model = MealAnalysisModel.fromJson(json);
      expect(model.totalCalories, equals(0));
      expect(model.totalProteins, equals(0));
    });

    test('toEntity() doit retourner une MealAnalysis valide', () {
      final json = {
        'foods': [],
        'totalCalories': 500.0,
        'totalProteins': 30.0,
        'totalCarbs': 60.0,
        'totalFats': 10.0,
        'suggestions': ['Test'],
      };

      final entity = MealAnalysisModel.fromJson(json).toEntity();
      expect(entity.totalCalories, equals(500.0));
      expect(entity.suggestions, contains('Test'));
    });

    test('doit parser plusieurs aliments', () {
      final json = {
        'foods': [
          {'name': 'A', 'calories': 100.0, 'proteins': 5.0, 'carbs': 20.0, 'fats': 1.0},
          {'name': 'B', 'calories': 200.0, 'proteins': 10.0, 'carbs': 30.0, 'fats': 2.0},
        ],
        'totalCalories': 300.0,
        'totalProteins': 15.0,
        'totalCarbs': 50.0,
        'totalFats': 3.0,
        'suggestions': [],
      };

      final model = MealAnalysisModel.fromJson(json);
      expect(model.foods.length, equals(2));
    });

    test('toJson() puis fromJson() doit produire le même modèle', () {
      const original = MealAnalysisModel(
        foods: [],
        totalCalories: 350.0,
        totalProteins: 25.0,
        totalCarbs: 40.0,
        totalFats: 8.0,
        suggestions: ['Conseil A', 'Conseil B'],
      );

      final roundTripped = MealAnalysisModel.fromJson(original.toJson());
      expect(roundTripped.totalCalories, equals(original.totalCalories));
      expect(roundTripped.suggestions.length, equals(2));
    });

    test('FoodItemModel.fromJson doit gérer un nom vide', () {
      final json = {
        'name': null,
        'calories': 50.0,
        'proteins': 2.0,
        'carbs': 10.0,
        'fats': 0.5,
      };

      final model = FoodItemModel.fromJson(json);
      expect(model.name, equals(''));
    });
  });
}
