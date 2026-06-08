import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/meal_plan.dart';
import '../providers/meal_plan_provider.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  int _calories = 2000;
  String _goal = 'weight_loss';
  final List<String> _allergies = [];

  static const _goals = [
    ('weight_loss', 'Perte de poids'),
    ('muscle_gain', 'Prise de muscle'),
    ('maintenance', 'Maintien'),
  ];

  static const _allergyOptions = [
    'gluten', 'dairy', 'nuts', 'eggs', 'soy', 'fish',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plan de repas IA'),
        actions: [
          if (state.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _generate,
              tooltip: 'Régénérer',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PreferencesCard(
              calories: _calories,
              goal: _goal,
              allergies: _allergies,
              goals: _goals,
              allergyOptions: _allergyOptions,
              onCaloriesChanged: (v) => setState(() => _calories = v),
              onGoalChanged: (v) => setState(() => _goal = v),
              onAllergyToggled: (a) => setState(() {
                _allergies.contains(a)
                    ? _allergies.remove(a)
                    : _allergies.add(a);
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: state is AsyncLoading ? null : _generate,
              icon: state is AsyncLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                  state is AsyncLoading ? 'Génération...' : 'Générer mon menu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            state.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Spoonacular recherche vos recettes…',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              error: (e, _) => ErrorCardWidget(error: e, context: 'MealPlan', onRetry: _generate),
              data: (plan) {
                if (plan == null) return const SizedBox.shrink();
                return _MealPlanResult(plan: plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _generate() {
    ref.read(mealPlanProvider.notifier).generate(
          calories: _calories,
          allergies: _allergies,
          goal: _goal,
        );
  }
}

// ─── Préférences ────────────────────────────────────────────────────────────

class _PreferencesCard extends StatelessWidget {
  final int calories;
  final String goal;
  final List<String> allergies;
  final List<(String, String)> goals;
  final List<String> allergyOptions;
  final ValueChanged<int> onCaloriesChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onAllergyToggled;

  const _PreferencesCard({
    required this.calories,
    required this.goal,
    required this.allergies,
    required this.goals,
    required this.allergyOptions,
    required this.onCaloriesChanged,
    required this.onGoalChanged,
    required this.onAllergyToggled,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text('MES PRÉFÉRENCES',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.08,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Calories slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Objectif calorique',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              Text('$calories kcal',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          Slider(
            value: calories.toDouble(),
            min: 1200,
            max: 3500,
            divisions: 23,
            activeColor: AppColors.primary,
            onChanged: (v) => onCaloriesChanged(v.toInt()),
          ),
          const SizedBox(height: 8),
          // Objectif
          const Text('Objectif',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: goals
                .map((g) => ChoiceChip(
                      label: Text(g.$2),
                      selected: goal == g.$1,
                      selectedColor: AppColors.primaryLight,
                      onSelected: (_) => onGoalChanged(g.$1),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Allergies
          const Text('Allergies / intolérances',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: allergyOptions
                .map((a) => FilterChip(
                      label: Text(a),
                      selected: allergies.contains(a),
                      selectedColor: const Color(0xFFFFEBEE),
                      checkmarkColor: const Color(0xFFD04040),
                      onSelected: (_) => onAllergyToggled(a),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Résultat ────────────────────────────────────────────────────────────────

class _MealPlanResult extends StatelessWidget {
  final GeneratedMealPlan plan;
  const _MealPlanResult({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'Total journée : ${plan.totalCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _RecipeCard(recipe: plan.lunch, label: 'DÉJEUNER'),
        const SizedBox(height: 12),
        _RecipeCard(recipe: plan.dinner, label: 'DÎNER'),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final MealPlanRecipe recipe;
  final String label;
  const _RecipeCard({required this.recipe, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + label
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: recipe.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 160,
                          color: AppColors.surfaceAlt,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 160,
                          color: AppColors.surfaceAlt,
                          child: const Icon(Icons.restaurant,
                              size: 48, color: AppColors.textTertiary),
                        ),
                      )
                    : Container(
                        height: 160,
                        color: AppColors.surfaceAlt,
                        child: const Icon(Icons.restaurant,
                            size: 48, color: AppColors.textTertiary),
                      ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              if (recipe.score > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text('${recipe.score}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                // Macros row
                Row(
                  children: [
                    _MacroChip('${recipe.calories.toStringAsFixed(0)} kcal',
                        AppColors.primary),
                    const SizedBox(width: 6),
                    _MacroChip('${recipe.protein.toStringAsFixed(0)}g prot.',
                        const Color(0xFF1565C0)),
                    const SizedBox(width: 6),
                    _MacroChip('${recipe.carbs.toStringAsFixed(0)}g gl.',
                        const Color(0xFF6A1B9A)),
                  ],
                ),
                const SizedBox(height: 10),
                // Méta
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text('${recipe.preparationTime} min',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textTertiary)),
                    const SizedBox(width: 12),
                    const Icon(Icons.euro_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                        '${(recipe.pricePerServing / 100).toStringAsFixed(2)} €/pers.',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
                if (recipe.diets.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: recipe.diets
                        .map((d) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(d,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.primary)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                // Ingrédients
                const Text('Ingrédients',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: recipe.ingredients
                      .take(8)
                      .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(i,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ))
                      .toList(),
                ),
                if (recipe.ingredients.length > 8)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        '+${recipe.ingredients.length - 8} autres ingrédients',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _MacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD04040).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD04040), size: 32),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
