import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/meal_history_item.dart';
import '../providers/nutrition_provider.dart';

class NutritionHubScreen extends ConsumerWidget {
  const NutritionHubScreen({super.key});

  // Objectifs journaliers de référence (en attendant /api/user/profile)
  static const double _calorieTarget = 2200;
  static const double _proteinTarget = 150;
  static const double _carbsTarget = 280;
  static const double _fatTarget = 73;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dailyStatsProvider);
    final historyAsync = ref.watch(nutritionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nutrition',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (statsAsync.isLoading || historyAsync.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(dailyStatsProvider);
              ref.invalidate(nutritionHistoryProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            statsAsync.when(
              data: (stats) => _buildDaySummaryCard(stats),
              loading: () => _buildDaySummaryCard(DailyStats.empty),
              error: (_, __) => _buildDaySummaryCard(DailyStats.empty),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => _buildMacroGrid(stats),
              loading: () => _buildMacroGrid(DailyStats.empty),
              error: (_, __) => _buildMacroGrid(DailyStats.empty),
            ),
            const SizedBox(height: 24),
            _buildAnalyzeSection(context),
            const SizedBox(height: 24),
            historyAsync.when(
              data: (history) => _buildRecentMeals(history),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => _buildRecentMeals([]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySummaryCard(DailyStats stats) {
    final ratio = _calorieTarget > 0 ? (stats.calories / _calorieTarget).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RÉSUMÉ DU JOUR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.08,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.surfaceAlt,
                      color: AppColors.primary,
                      strokeWidth: 6,
                    ),
                    Center(
                      child: Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'sur ${_calorieTarget.toStringAsFixed(0)} kcal objectif',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.surfaceAlt,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroGrid(DailyStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _MacroCard(
          label: 'PROTÉINES',
          value: stats.protein.toStringAsFixed(0),
          target: _proteinTarget.toStringAsFixed(0),
          unit: 'g',
          color: AppColors.primary,
        ),
        _MacroCard(
          label: 'GLUCIDES',
          value: stats.carbs.toStringAsFixed(0),
          target: _carbsTarget.toStringAsFixed(0),
          unit: 'g',
          color: AppColors.accent,
        ),
        _MacroCard(
          label: 'LIPIDES',
          value: stats.fat.toStringAsFixed(0),
          target: _fatTarget.toStringAsFixed(0),
          unit: 'g',
          color: const Color(0xFFE07B5F),
        ),
        _MacroCard(
          label: 'SÉANCES',
          value: stats.workoutsCount.toString(),
          target: '5',
          unit: '',
          color: const Color(0xFF7BB8E0),
        ),
      ],
    );
  }

  Widget _buildAnalyzeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ANALYSER UN REPAS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.08,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Photo'),
                onPressed: () => context.push('/camera'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
                onPressed: () => _pickFromGallery(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      final compressed = await ImageUtils.compress(picked.path);
      if (context.mounted) {
        context.push('/meal-result', extra: compressed);
      }
    }
  }

  Widget _buildRecentMeals(List<MealHistoryItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DERNIERS REPAS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.08,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.card,
            ),
            child: const Center(
              child: Text(
                'Aucun repas enregistré aujourd\'hui',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: history.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 0.5, indent: 56),
                    _buildMealRow(
                      item.date,
                      '${item.calories.toStringAsFixed(0)} kcal',
                      Icons.restaurant_outlined,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMealRow(String name, String calories, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            calories,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final v = double.tryParse(value) ?? 0;
    final t = double.tryParse(target) ?? 1;
    final ratio = (v / t).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.07,
              color: AppColors.textTertiary,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            unit.isEmpty ? '$value / $target' : '$value / $target $unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.surfaceAlt,
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
