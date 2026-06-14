import 'dart:math';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  @override
  Future<GeneratedMealPlan> generateMealPlan({
    required int dailyCaloriesTarget,
    required List<String> allergies,
    required String goal,
  }) async {
    // Démo présentation : l'IA de génération de menu renvoie des résultats
    // peu fiables, on pioche parmi des exemples réalistes pré-calculés.
    await Future.delayed(const Duration(milliseconds: 1500));
    return _demoPlans[Random().nextInt(_demoPlans.length)];
  }

  static const List<GeneratedMealPlan> _demoPlans = [
    // Exemple 1 — perte de poids
    GeneratedMealPlan(
      lunch: MealPlanRecipe(
        id: 1001,
        name: 'Salade de poulet grillé au quinoa',
        ingredients: [
          'Blanc de poulet',
          'Quinoa',
          'Tomates cerises',
          'Concombre',
          'Feta',
          'Citron',
          "Huile d'olive",
        ],
        calories: 420,
        protein: 38,
        carbs: 35,
        fat: 14,
        sugar: 6,
        sodium: 480,
        pricePerServing: 320,
        preparationTime: 20,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/2/2c/Chicken_Fillet_Salad.JPG',
        diets: ['gluten free'],
        dishTypes: ['salad', 'lunch'],
        score: 92,
      ),
      dinner: MealPlanRecipe(
        id: 1002,
        name: 'Saumon vapeur, brocolis et riz complet',
        ingredients: [
          'Pavé de saumon',
          'Brocoli',
          'Riz complet',
          'Citron',
          'Aneth',
          "Huile d'olive",
        ],
        calories: 480,
        protein: 36,
        carbs: 42,
        fat: 16,
        sugar: 3,
        sodium: 390,
        pricePerServing: 450,
        preparationTime: 25,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/34/Salmon_dish.jpg',
        diets: ['pescatarian'],
        dishTypes: ['dinner', 'main course'],
        score: 95,
      ),
      totalCalories: 900,
    ),

    // Exemple 2 — prise de muscle
    GeneratedMealPlan(
      lunch: MealPlanRecipe(
        id: 1003,
        name: 'Wrap au bœuf, riz et légumes sautés',
        ingredients: [
          'Tortilla de blé',
          'Bœuf haché 5%',
          'Riz',
          'Poivrons',
          'Oignon',
          'Sauce soja',
        ],
        calories: 650,
        protein: 45,
        carbs: 70,
        fat: 20,
        sugar: 8,
        sodium: 620,
        pricePerServing: 380,
        preparationTime: 18,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/c0/Beef_and_vegetable_tortilla_wrap.jpg',
        diets: [],
        dishTypes: ['lunch', 'main course'],
        score: 88,
      ),
      dinner: MealPlanRecipe(
        id: 1004,
        name: 'Pâtes complètes au thon et parmesan',
        ingredients: [
          'Pâtes complètes',
          'Thon',
          'Parmesan',
          'Tomates',
          'Ail',
          'Basilic',
        ],
        calories: 720,
        protein: 42,
        carbs: 90,
        fat: 18,
        sugar: 5,
        sodium: 540,
        pricePerServing: 290,
        preparationTime: 22,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d6/Pasta_with_Tuna_%284690353672%29.jpg',
        diets: ['pescatarian'],
        dishTypes: ['dinner', 'pasta'],
        score: 90,
      ),
      totalCalories: 1370,
    ),

    // Exemple 3 — maintien / équilibré
    GeneratedMealPlan(
      lunch: MealPlanRecipe(
        id: 1005,
        name: 'Bowl végétarien pois chiches et avocat',
        ingredients: [
          'Pois chiches',
          'Avocat',
          'Quinoa',
          'Carottes',
          'Épinards',
          'Tahini',
        ],
        calories: 480,
        protein: 18,
        carbs: 60,
        fat: 18,
        sugar: 7,
        sodium: 410,
        pricePerServing: 260,
        preparationTime: 15,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/Power_protein_salad_bowl.jpg',
        diets: ['vegetarian', 'vegan'],
        dishTypes: ['lunch', 'salad'],
        score: 87,
      ),
      dinner: MealPlanRecipe(
        id: 1006,
        name: 'Omelette aux champignons et salade verte',
        ingredients: [
          'Œufs',
          'Champignons',
          'Salade verte',
          'Tomates',
          "Huile d'olive",
          'Persil',
        ],
        calories: 380,
        protein: 24,
        carbs: 12,
        fat: 26,
        sugar: 3,
        sodium: 350,
        pricePerServing: 180,
        preparationTime: 12,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/f/f3/Omelette_aux_girolles_0002.jpg',
        diets: ['vegetarian', 'gluten free'],
        dishTypes: ['dinner', 'breakfast'],
        score: 84,
      ),
      totalCalories: 860,
    ),
  ];
}
