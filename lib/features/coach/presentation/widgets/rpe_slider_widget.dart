import 'package:flutter/material.dart';

class RpeSliderWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const RpeSliderWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _label(int v) {
    if (v <= 3) return 'Très facile 😴';
    if (v <= 5) return 'Modéré 🙂';
    if (v <= 7) return 'Difficile 💪';
    if (v <= 9) return 'Très difficile 🔥';
    return 'Maximum 💀';
  }

  Color _color(int v) {
    if (v <= 3) return Colors.green;
    if (v <= 7) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(value);

    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          _label(value),
          style: TextStyle(fontSize: 20, color: color),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            inactiveTrackColor: color.withValues(alpha: 0.3),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1', style: TextStyle(color: Colors.grey)),
            Text('10', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
