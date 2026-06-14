import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/meal_history_item.dart';

/// Persistance locale (mock) du suivi nutritionnel du jour.
///
/// L'historique est conservé en SharedPreferences et réinitialisé
/// automatiquement dès que la date change.
class NutritionLocalStorage {
  static const _dateKey = 'nutrition_log_date_v1';
  static const _historyKey = 'nutrition_log_history_v1';

  Future<List<MealHistoryItem>> loadTodayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_dateKey) != _todayKey()) return [];

    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTodayHistory(List<MealHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, _todayKey());
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map(_toJson).toList()),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _toJson(MealHistoryItem item) => {
        'id': item.id,
        'date': item.date,
        'imageUrl': item.imageUrl,
        'calories': item.calories,
        'protein': item.protein,
        'carbs': item.carbs,
        'fat': item.fat,
      };

  MealHistoryItem _fromJson(Map<String, dynamic> json) => MealHistoryItem(
        id: json['id'] as String,
        date: json['date'] as String,
        imageUrl: json['imageUrl'] as String?,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
      );
}
