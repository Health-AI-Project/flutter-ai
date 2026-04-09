import '../../domain/entities/meal_plan.dart';

class MealPlanRecipeModel {
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

  const MealPlanRecipeModel({
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

  factory MealPlanRecipeModel.fromJson(Map<String, dynamic> json) {
    return MealPlanRecipeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      pricePerServing: (json['pricePerServing'] as num?)?.toDouble() ?? 0,
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      diets: (json['diets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dishTypes: (json['dishTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }

  MealPlanRecipe toEntity() => MealPlanRecipe(
        id: id,
        name: name,
        ingredients: ingredients,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        sugar: sugar,
        sodium: sodium,
        pricePerServing: pricePerServing,
        preparationTime: preparationTime,
        imageUrl: imageUrl,
        diets: diets,
        dishTypes: dishTypes,
        score: score,
      );
}

class GeneratedMealPlanModel {
  final MealPlanRecipeModel lunch;
  final MealPlanRecipeModel dinner;
  final double totalCalories;

  const GeneratedMealPlanModel({
    required this.lunch,
    required this.dinner,
    required this.totalCalories,
  });

  factory GeneratedMealPlanModel.fromJson(Map<String, dynamic> json) {
    return GeneratedMealPlanModel(
      lunch: MealPlanRecipeModel.fromJson(json['lunch'] as Map<String, dynamic>),
      dinner: MealPlanRecipeModel.fromJson(json['dinner'] as Map<String, dynamic>),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
    );
  }

  GeneratedMealPlan toEntity() => GeneratedMealPlan(
        lunch: lunch.toEntity(),
        dinner: dinner.toEntity(),
        totalCalories: totalCalories,
      );
}
