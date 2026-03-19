import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/macro_table_widget.dart';

class MealResultScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const MealResultScreen({super.key, required this.imagePath});

  @override
  ConsumerState<MealResultScreen> createState() => _MealResultScreenState();
}

class _MealResultScreenState extends ConsumerState<MealResultScreen> {
  static const String _hardcodedUserId = 'user_placeholder';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('Début analyse — imagePath : ${widget.imagePath}');
      try {
        await ref
            .read(nutritionProvider.notifier)
            .analyzeMeal(widget.imagePath, _hardcodedUserId);
        debugPrint('Analyse terminée avec succès');
      } catch (e, stackTrace) {
        debugPrint('ERREUR analyzeMeal : $e');
        debugPrint('Stack trace : $stackTrace');
      }
    });
  }

  @override
  void dispose() {
    ref.read(nutritionProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);

    ref.listen<AsyncValue>(nutritionProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                ref
                    .read(nutritionProvider.notifier)
                    .analyzeMeal(widget.imagePath, _hardcodedUserId);
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats nutritionnels'),
      ),
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
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyse en cours…'),
                    ],
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(nutritionProvider.notifier)
                            .analyzeMeal(widget.imagePath, _hardcodedUserId);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (analysis) {
                if (analysis == null) {
                  return const Center(child: CircularProgressIndicator());
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
