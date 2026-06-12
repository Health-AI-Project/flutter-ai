import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/coach/presentation/widgets/exercise_card_widget.dart';
import 'package:healthai_coach_mobile/features/offline/domain/entities/exercise.dart';

void main() {
  const longExercise = Exercise(
    name: 'Planche',
    sets: 3,
    reps: 1,
    restSeconds: 30,
    muscleGroup: 'Abdominaux',
  );

  testWidgets(
      'ExerciseCardWidget ne déborde pas sur un écran de téléphone étroit',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseCardWidget(exercise: longExercise)),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Planche'), findsOneWidget);
    expect(find.textContaining('Repos : 30s'), findsOneWidget);
  });
}
