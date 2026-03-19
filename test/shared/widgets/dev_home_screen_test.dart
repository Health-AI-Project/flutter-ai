import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/shared/screens/dev_home_screen.dart';

void main() {
  group('DevHomeScreen', () {
    testWidgets('doit afficher le titre de l\'application', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.text('HealthAI Coach — Dev'), findsOneWidget);
    });

    testWidgets('doit afficher le bouton Feature A', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.textContaining('Feature A'), findsOneWidget);
    });

    testWidgets('doit afficher le bouton Feature B', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.textContaining('Feature B'), findsOneWidget);
    });

    testWidgets('doit afficher le bouton Feature C', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.textContaining('Feature C'), findsOneWidget);
    });

    testWidgets('doit afficher le label Mode Test', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.text('Mode Test'), findsOneWidget);
    });

    testWidgets('doit afficher exactement 3 boutons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DevHomeScreen()),
        ),
      );
      expect(find.byType(ElevatedButton), findsNWidgets(3));
    });
  });
}
