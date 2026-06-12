import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/auth/presentation/screens/login_screen.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('LoginScreen', () {
    testWidgets(
        'le lien "Mot de passe oublié ?" ouvre une boîte de dialogue et affiche une confirmation',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié'), findsOneWidget);
      expect(find.text('Envoyer'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'test@example.com');
      await tester.tap(find.text('Envoyer'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Si un compte existe avec cet email, un lien de réinitialisation a été envoyé.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'le bouton "Annuler" de la boîte "mot de passe oublié" ferme le dialogue sans confirmation',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié'), findsNothing);
      expect(
        find.text(
            'Si un compte existe avec cet email, un lien de réinitialisation a été envoyé.'),
        findsNothing,
      );
    });

    testWidgets('le bouton Google affiche un message "bientôt disponible"',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.scrollUntilVisible(
        find.text('Google'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Google'));
      await tester.pump();

      expect(find.text('Connexion via Google bientôt disponible'), findsOneWidget);
    });

    testWidgets('le bouton Apple affiche un message "bientôt disponible"',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.scrollUntilVisible(
        find.text('Apple'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Apple'));
      await tester.pump();

      expect(find.text('Connexion via Apple bientôt disponible'), findsOneWidget);
    });
  });
}
