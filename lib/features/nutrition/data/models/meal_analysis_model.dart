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
  final String? detectedFood;
  final double? confidence;
  final bool? isSafe;
  final List<String> warnings;
  final String? advice;

  const MealAnalysisModel({
    required this.foods,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    required this.suggestions,
    this.detectedFood,
    this.confidence,
    this.isSafe,
    this.warnings = const [],
    this.advice,
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

  /// Construit un MealAnalysisModel depuis la réponse de /api/nutrition/upload
  factory MealAnalysisModel.fromUploadJson(Map<String, dynamic> json) {
    final macros = json['macros'] as Map<String, dynamic>? ?? {};
    final calories = (macros['calories'] as num?)?.toDouble() ?? 0;
    final protein = (macros['protein'] as num?)?.toDouble() ?? 0;
    final carbs = (macros['carbs'] as num?)?.toDouble() ?? 0;
    final fat = (macros['fat'] as num?)?.toDouble() ?? 0;
    final detectedFood = json['detectedFood'] as String?;
    final confidence = (json['confidence'] as num?)?.toDouble();

    return MealAnalysisModel(
      foods: [
        FoodItemModel(
          name: detectedFood ?? 'Repas analysé',
          calories: calories,
          proteins: protein,
          carbs: carbs,
          fats: fat,
        ),
      ],
      totalCalories: calories,
      totalProteins: protein,
      totalCarbs: carbs,
      totalFats: fat,
      suggestions: [],
      detectedFood: detectedFood,
      confidence: confidence,
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
        detectedFood: detectedFood,
        confidence: confidence,
        isSafe: isSafe,
        warnings: warnings,
        advice: advice,
      );

  MealAnalysisModel withAiAnalysis({
    required bool isSafe,
    required List<String> warnings,
    required String advice,
  }) {
    return MealAnalysisModel(
      foods: foods,
      totalCalories: totalCalories,
      totalProteins: totalProteins,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      suggestions: suggestions,
      detectedFood: detectedFood,
      confidence: confidence,
      isSafe: isSafe,
      warnings: warnings,
      advice: advice,
    );
  }
}
