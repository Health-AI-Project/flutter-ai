import '../../domain/entities/meal_analysis.dart';

class FoodItemModel {
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  const FoodItemModel({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      name: (json['name'] as String?) ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteins: (json['proteins'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fats': fats,
      };

  FoodItem toEntity() => FoodItem(
        name: name,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
      );
}

class MealAnalysisModel {
  final List<FoodItemModel> foods;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final List<String> suggestions;

  const MealAnalysisModel({
    required this.foods,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    required this.suggestions,
  });

  factory MealAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawFoods = json['foods'] as List<dynamic>? ?? [];
    return MealAnalysisModel(
      foods: rawFoods
          .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProteins: (json['totalProteins'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFats: (json['totalFats'] as num?)?.toDouble() ?? 0,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'foods': foods.map((e) => e.toJson()).toList(),
        'totalCalories': totalCalories,
        'totalProteins': totalProteins,
        'totalCarbs': totalCarbs,
        'totalFats': totalFats,
        'suggestions': suggestions,
      };

  MealAnalysis toEntity() => MealAnalysis(
        foods: foods.map((e) => e.toEntity()).toList(),
        totalCalories: totalCalories,
        totalProteins: totalProteins,
        totalCarbs: totalCarbs,
        totalFats: totalFats,
        suggestions: suggestions,
      );
}
