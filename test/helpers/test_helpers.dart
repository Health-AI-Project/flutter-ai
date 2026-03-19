import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/day_plan.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/exercise.dart';

/// Wrapper minimal pour tester des widgets avec Riverpod
Widget buildTestableWidget(Widget widget, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: widget,
    ),
  );
}

const testExercise = Exercise(
  name: 'Test Exercice',
  sets: 3,
  reps: 10,
  restSeconds: 5,
  muscleGroup: 'Test',
);

const testDayPlan = DayPlan(
  day: 'Lundi',
  sessionType: 'Test',
  durationMinutes: 30,
  isRestDay: false,
  exercises: [testExercise],
);
