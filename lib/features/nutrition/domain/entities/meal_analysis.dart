class MealAnalysis {
  final List<FoodItem> foods;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final List<String> suggestions;

  // Champs reconnaissance visuelle (service Python)
  final String? detectedFood;
  final double? confidence;

  // Champs IA (POST /api/nutrition/analyze)
  final bool? isSafe;
  final List<String> warnings;
  final String? advice;

  const MealAnalysis({
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

  bool get hasMacros => totalProteins > 0 || totalCarbs > 0 || totalFats > 0;

  MealAnalysis copyWith({
    List<FoodItem>? foods,
    double? totalCalories,
    double? totalProteins,
    double? totalCarbs,
    double? totalFats,
    List<String>? suggestions,
    String? detectedFood,
    double? confidence,
    bool? isSafe,
    List<String>? warnings,
    String? advice,
  }) {
    return MealAnalysis(
      foods: foods ?? this.foods,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteins: totalProteins ?? this.totalProteins,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFats: totalFats ?? this.totalFats,
      suggestions: suggestions ?? this.suggestions,
      detectedFood: detectedFood ?? this.detectedFood,
      confidence: confidence ?? this.confidence,
      isSafe: isSafe ?? this.isSafe,
      warnings: warnings ?? this.warnings,
      advice: advice ?? this.advice,
    );
  }
}

class FoodItem {
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  FoodItem copyWith({
    String? name,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }
}
