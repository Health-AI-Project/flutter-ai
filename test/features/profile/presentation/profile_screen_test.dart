import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:healthai_coach_mobile/core/auth/token_storage.dart';
import 'package:healthai_coach_mobile/core/constants/local_storage_keys.dart';
import 'package:healthai_coach_mobile/core/network/dio_client.dart';
import 'package:healthai_coach_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_helpers.dart';

/// Adaptateur Dio qui échoue immédiatement, sans réseau ni timer réel,
/// afin que `_loadProfile` bascule tout de suite sur sa branche
/// `on DioException` (comme en environnement de test sans accès réseau).
class _ImmediateErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.error(Exception('Pas de réseau en environnement de test'));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    DioClient.instance.httpClientAdapter = _ImmediateErrorAdapter();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileScreen', () {
    testWidgets('modifier le nom met à jour l\'affichage et persiste la valeur',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mon profil'));
      await tester.pumpAndSettle();

      expect(find.text('Modifier le nom'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Killian Pinte');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Killian Pinte'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStorageKeys.profileDisplayName), 'Killian Pinte');
    });

    testWidgets('le switch notifications persiste sa valeur', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(LocalStorageKeys.profileNotificationsEnabled), isFalse);

      final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(updatedSwitch.value, isFalse);
    });

    testWidgets('le bouton de déconnexion efface le token et redirige vers /login',
        (tester) async {
      await TokenStorage.save('fake_token', userId: 'user_42');

      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('Page de connexion')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(find.text('Page de connexion'), findsOneWidget);
      expect(await TokenStorage.get(), isNull);
      expect(await TokenStorage.getUserId(), isNull);
    });
  });
}
