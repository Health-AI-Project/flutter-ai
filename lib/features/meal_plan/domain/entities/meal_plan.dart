class MealPlanRecipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double sodium;
  final double pricePerServing;
  final int preparationTime;
  final String? imageUrl;
  final List<String> diets;
  final List<String> dishTypes;
  final int score;

  const MealPlanRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.sodium,
    required this.pricePerServing,
    required this.preparationTime,
    this.imageUrl,
    required this.diets,
    required this.dishTypes,
    required this.score,
  });

  MealPlanRecipe copyWith({double? calories}) => MealPlanRecipe(
        id: id, name: name, ingredients: ingredients,
        calories: calories ?? this.calories,
        protein: protein, carbs: carbs, fat: fat,
        sugar: sugar, sodium: sodium, pricePerServing: pricePerServing,
        preparationTime: preparationTime, imageUrl: imageUrl,
        diets: diets, dishTypes: dishTypes, score: score,
      );
}

class GeneratedMealPlan {
  final MealPlanRecipe lunch;
  final MealPlanRecipe dinner;
  final double totalCalories;

  const GeneratedMealPlan({
    required this.lunch,
    required this.dinner,
    required this.totalCalories,
  });
}
