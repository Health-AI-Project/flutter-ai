import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timerSeconds;
  final int totalSeconds;

  const TimerWidget({
    super.key,
    required this.timerSeconds,
    required this.totalSeconds,
  });

  Color _timerColor() {
    if (totalSeconds == 0) return Colors.green;
    final ratio = timerSeconds / totalSeconds;
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds > 0 ? timerSeconds / totalSeconds : 0.0;
    final color = _timerColor();

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              strokeWidth: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$timerSeconds',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'sec',
                style: TextStyle(fontSize: 14, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
