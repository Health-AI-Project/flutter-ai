import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/macro_table_widget.dart';

class MealResultScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const MealResultScreen({super.key, required this.imagePath});

  @override
  ConsumerState<MealResultScreen> createState() => _MealResultScreenState();
}

class _MealResultScreenState extends ConsumerState<MealResultScreen> {
  late final NutritionNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(nutritionProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await TokenStorage.getUserId() ?? 'guest';
      try {
        await _notifier.analyzeMeal(widget.imagePath, userId);
      } catch (e) {
        debugPrint('ERREUR analyzeMeal : $e');
      }
    });
  }

  @override
  void dispose() {
    Future(() => _notifier.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);

    ref.listen<AsyncValue>(nutritionProvider, (_, next) {
      if (next is AsyncError && context.mounted) {
        final appError = parseError(next.error, context: 'NutritionUpload');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appError.userMessage),
            backgroundColor: const Color(0xFFD04040),
            duration: const Duration(seconds: 5),
            action: appError.isRetryable
                ? SnackBarAction(
                    label: 'Réessayer',
                    textColor: AppColors.textOnPrimary,
                    onPressed: () async {
                      final userId = await TokenStorage.getUserId() ?? 'guest';
                      _notifier.analyzeMeal(widget.imagePath, userId);
                    },
                  )
                : null,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Résultats nutritionnels')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            nutritionState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        'Analyse en cours…',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, _) => ErrorStateWidget(
                error: error,
                context: 'NutritionUpload',
                icon: Icons.restaurant_outlined,
                onRetry: () async {
                  final userId = await TokenStorage.getUserId() ?? 'guest';
                  _notifier.analyzeMeal(widget.imagePath, userId);
                },
              ),
              data: (analysis) {
                if (analysis == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (analysis.detectedFood != null)
                      _DetectionBanner(
                        food: analysis.detectedFood!,
                        confidence: analysis.confidence ?? 0,
                      ),
                    if (analysis.detectedFood != null)
                      const SizedBox(height: 16),
                    if (!analysis.hasMacros)
                      const _IncompleteMacrosBanner(),
                    if (!analysis.hasMacros)
                      const SizedBox(height: 16),
                    MacroTableWidget(analysis: analysis),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Banner aliment détecté ───────────────────────────────────────────────────

class _DetectionBanner extends StatelessWidget {
  final String food;
  final double confidence;

  const _DetectionBanner({required this.food, required this.confidence});

  Color get _confidenceColor {
    if (confidence >= 0.85) return AppColors.primary;
    if (confidence >= 0.60) return const Color(0xFFF59E0B);
    return const Color(0xFFD04040);
  }

  String get _confidenceLabel {
    if (confidence >= 0.85) return 'Haute confiance';
    if (confidence >= 0.60) return 'Confiance modérée';
    return 'Faible confiance';
  }

  String get _foodLabel {
    // Traduction simple des classes anglaises → français
    const labels = {
      'donuts': 'Donuts',
      'pancakes': 'Pancakes',
      'cup_cakes': 'Cupcakes',
      'french_fries': 'Frites',
      'pizza': 'Pizza',
      'burger': 'Burger',
      'salad': 'Salade',
      'chicken': 'Poulet',
      'rice': 'Riz',
      'pasta': 'Pâtes',
      'sushi': 'Sushi',
      'soup': 'Soupe',
      'sandwich': 'Sandwich',
      'steak': 'Steak',
      'apple': 'Pomme',
      'banana': 'Banane',
      'chocolate_cake': 'Gâteau au chocolat',
      'ice_cream': 'Glace',
      'waffles': 'Gaufres',
      'omelette': 'Omelette',
    };
    return labels[food] ?? food.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _confidenceColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _confidenceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: _confidenceColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aliment détecté : $_foodLabel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _confidenceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_confidenceLabel — ${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _confidenceColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Barre de confiance circulaire
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: confidence.clamp(0.0, 1.0),
                  backgroundColor: _confidenceColor.withOpacity(0.15),
                  color: _confidenceColor,
                  strokeWidth: 3,
                ),
                Center(
                  child: Text(
                    '${(confidence * 100).round()}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner macros incomplètes ────────────────────────────────────────────────

class _IncompleteMacrosBanner extends StatelessWidget {
  const _IncompleteMacrosBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Protéines, glucides et lipides non disponibles. Utilisez "Corriger" pour les saisir manuellement.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}
