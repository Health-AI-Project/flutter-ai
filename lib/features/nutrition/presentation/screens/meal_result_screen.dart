import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/token_storage.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: const Color(0xFFD04040),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: AppColors.textOnPrimary,
              onPressed: () async {
                final userId = await TokenStorage.getUserId() ?? 'guest';
                _notifier.analyzeMeal(widget.imagePath, userId);
              },
            ),
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
              error: (error, _) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFD04040)),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final userId = await TokenStorage.getUserId() ?? 'guest';
                        _notifier.analyzeMeal(widget.imagePath, userId);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (analysis) {
                if (analysis == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return MacroTableWidget(analysis: analysis);
              },
            ),
          ],
        ),
      ),
    );
  }
}
