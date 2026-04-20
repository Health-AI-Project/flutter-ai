class DailyStats {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int workoutsCount;

  const DailyStats({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.workoutsCount,
  });

  static const empty = DailyStats(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    workoutsCount: 0,
  );
}
