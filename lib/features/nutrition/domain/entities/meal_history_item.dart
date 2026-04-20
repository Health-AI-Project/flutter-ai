class MealHistoryItem {
  final String id;
  final String date;
  final String? imageUrl;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealHistoryItem({
    required this.id,
    required this.date,
    this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  static MealHistoryItem fromJson(Map<String, dynamic> json) {
    final macros = json['macros'] as Map<String, dynamic>? ?? {};
    return MealHistoryItem(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      calories: (macros['calories'] as num?)?.toDouble() ?? 0,
      protein: (macros['protein'] as num?)?.toDouble() ?? 0,
      carbs: (macros['carbs'] as num?)?.toDouble() ?? 0,
      fat: (macros['fat'] as num?)?.toDouble() ?? 0,
    );
  }
}
