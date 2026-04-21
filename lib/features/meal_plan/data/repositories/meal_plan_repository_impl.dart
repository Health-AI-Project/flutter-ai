import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../models/meal_plan_model.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<GeneratedMealPlan> generateMealPlan({
    required int dailyCaloriesTarget,
    required List<String> allergies,
    required String goal,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.generateMenu,
        data: {
          'user': {
            'dailyCaloriesTarget': dailyCaloriesTarget,
            'allergies': allergies,
            'goal': goal,
          },
        },
      );
      final model = GeneratedMealPlanModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return model.toEntity();
    } on DioException {
      return _mockPlanFor(goal, dailyCaloriesTarget);
    }
  }

  GeneratedMealPlan _mockPlanFor(String goal, int calories) {
    final lunchCal = (calories * 0.35).round().toDouble();
    final dinnerCal = (calories * 0.40).round().toDouble();
    final lunch = _lunchOptions[goal] ?? _lunchOptions['maintenance']!;
    final dinner = _dinnerOptions[goal] ?? _dinnerOptions['maintenance']!;
    return GeneratedMealPlan(
      lunch: lunch.copyWith(calories: lunchCal),
      dinner: dinner.copyWith(calories: dinnerCal),
      totalCalories: lunchCal + dinnerCal,
    );
  }

  static final _lunchOptions = {
    'weight_loss': MealPlanRecipe(
      id: 1001, name: 'Salade de poulet grillé', ingredients: ['Poulet', 'Laitue', 'Tomates', 'Concombre', 'Vinaigrette'],
      calories: 420, protein: 38, carbs: 22, fat: 14, sugar: 4, sodium: 480,
      pricePerServing: 6.5, preparationTime: 20, diets: ['gluten free'], dishTypes: ['lunch'], score: 88,
    ),
    'muscle_gain': MealPlanRecipe(
      id: 1002, name: 'Riz brun, œufs et légumes', ingredients: ['Riz brun', 'Œufs', 'Brocoli', 'Carottes', 'Huile d\'olive'],
      calories: 580, protein: 32, carbs: 68, fat: 16, sugar: 6, sodium: 320,
      pricePerServing: 5.0, preparationTime: 25, diets: [], dishTypes: ['lunch'], score: 85,
    ),
    'maintenance': MealPlanRecipe(
      id: 1003, name: 'Wrap au thon et avocat', ingredients: ['Tortilla', 'Thon', 'Avocat', 'Tomate', 'Salade'],
      calories: 510, protein: 28, carbs: 45, fat: 22, sugar: 3, sodium: 560,
      pricePerServing: 7.0, preparationTime: 15, diets: [], dishTypes: ['lunch'], score: 82,
    ),
  };

  static final _dinnerOptions = {
    'weight_loss': MealPlanRecipe(
      id: 2001, name: 'Saumon vapeur et haricots verts', ingredients: ['Saumon', 'Haricots verts', 'Citron', 'Ail', 'Huile d\'olive'],
      calories: 480, protein: 42, carbs: 18, fat: 24, sugar: 5, sodium: 290,
      pricePerServing: 9.5, preparationTime: 30, diets: ['gluten free', 'dairy free'], dishTypes: ['dinner'], score: 91,
    ),
    'muscle_gain': MealPlanRecipe(
      id: 2002, name: 'Steak de bœuf et patate douce', ingredients: ['Bœuf', 'Patate douce', 'Épinards', 'Beurre', 'Romarin'],
      calories: 680, protein: 48, carbs: 52, fat: 28, sugar: 8, sodium: 410,
      pricePerServing: 12.0, preparationTime: 35, diets: ['gluten free'], dishTypes: ['dinner'], score: 89,
    ),
    'maintenance': MealPlanRecipe(
      id: 2003, name: 'Poulet rôti et quinoa', ingredients: ['Poulet', 'Quinoa', 'Poivrons', 'Oignon', 'Herbes de Provence'],
      calories: 550, protein: 40, carbs: 48, fat: 18, sugar: 6, sodium: 380,
      pricePerServing: 8.5, preparationTime: 40, diets: ['gluten free', 'dairy free'], dishTypes: ['dinner'], score: 87,
    ),
  };
}
}
