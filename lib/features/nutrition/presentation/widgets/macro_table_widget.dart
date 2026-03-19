import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_analysis.dart';
import '../providers/nutrition_provider.dart';

class MacroTableWidget extends ConsumerStatefulWidget {
  final MealAnalysis analysis;

  const MacroTableWidget({super.key, required this.analysis});

  @override
  ConsumerState<MacroTableWidget> createState() => _MacroTableWidgetState();
}

class _MacroTableWidgetState extends ConsumerState<MacroTableWidget> {
  bool _editMode = false;
  late List<FoodItem> _editableFoods;
  late List<List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _initEditable();
  }

  void _initEditable() {
    _editableFoods = List.from(widget.analysis.foods);
    _controllers = _editableFoods.map((food) {
      return [
        TextEditingController(text: food.calories.toString()),
        TextEditingController(text: food.proteins.toString()),
        TextEditingController(text: food.carbs.toString()),
        TextEditingController(text: food.fats.toString()),
      ];
    }).toList();
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _validateEdits() {
    final updatedFoods = List.generate(_editableFoods.length, (i) {
      final food = _editableFoods[i];
      final cals = double.tryParse(_controllers[i][0].text) ?? food.calories;
      final prot = double.tryParse(_controllers[i][1].text) ?? food.proteins;
      final carbs = double.tryParse(_controllers[i][2].text) ?? food.carbs;
      final fats = double.tryParse(_controllers[i][3].text) ?? food.fats;
      return food.copyWith(
        calories: cals,
        proteins: prot,
        carbs: carbs,
        fats: fats,
      );
    });

    final totalCal = updatedFoods.fold(0.0, (s, f) => s + f.calories);
    final totalProt = updatedFoods.fold(0.0, (s, f) => s + f.proteins);
    final totalCarbs = updatedFoods.fold(0.0, (s, f) => s + f.carbs);
    final totalFats = updatedFoods.fold(0.0, (s, f) => s + f.fats);

    final updated = widget.analysis.copyWith(
      foods: updatedFoods,
      totalCalories: totalCal,
      totalProteins: totalProt,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );

    ref.read(nutritionProvider.notifier).updateFoodItem(0, updated);
    setState(() {
      _editableFoods = updatedFoods;
      _editMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = widget.analysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analyse nutritionnelle',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                if (_editMode) {
                  _validateEdits();
                } else {
                  setState(() => _editMode = true);
                }
              },
              icon: Icon(_editMode ? Icons.check : Icons.edit, size: 18),
              label: Text(_editMode ? 'Valider' : 'Corriger'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer,
            ),
            columns: const [
              DataColumn(label: Text('Aliment')),
              DataColumn(label: Text('Calories'), numeric: true),
              DataColumn(label: Text('Protéines'), numeric: true),
              DataColumn(label: Text('Glucides'), numeric: true),
              DataColumn(label: Text('Lipides'), numeric: true),
            ],
            rows: [
              ...List.generate(_editableFoods.length, (i) {
                final food = _editableFoods[i];
                return DataRow(cells: [
                  DataCell(Text(food.name)),
                  DataCell(_editMode
                      ? _editCell(_controllers[i][0])
                      : Text(food.calories.toStringAsFixed(1))),
                  DataCell(_editMode
                      ? _editCell(_controllers[i][1])
                      : Text(food.proteins.toStringAsFixed(1))),
                  DataCell(_editMode
                      ? _editCell(_controllers[i][2])
                      : Text(food.carbs.toStringAsFixed(1))),
                  DataCell(_editMode
                      ? _editCell(_controllers[i][3])
                      : Text(food.fats.toStringAsFixed(1))),
                ]);
              }),
              DataRow(
                cells: [
                  DataCell(Text('Total',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(
                    analysis.totalCalories.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    analysis.totalProteins.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    analysis.totalCarbs.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    analysis.totalFats.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ],
          ),
        ),
        if (analysis.suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Suggestions',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.suggestions
                .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 12,
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _editCell(TextEditingController controller) {
    return SizedBox(
      width: 72,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }
}
