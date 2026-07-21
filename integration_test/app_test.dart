import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ironcladbox_movil/main.dart' as app;
import 'test_config.dart';

const kLoginEmail = ValueKey('loginEmail');
const kLoginPassword = ValueKey('loginPassword');
const kLoginButton = ValueKey('loginButton');
const kLoginError = ValueKey('loginError');
const kAdminDashboard = ValueKey('adminDashboard');

const kAthletesMenu = ValueKey('athletesMenu');
const kNewAthleteButton = ValueKey('newAthleteButton');
const kAthleteName = ValueKey('athleteName');
const kAthleteLastname = ValueKey('athleteLastname');
const kAthleteEmail = ValueKey('athleteEmail');
const kAthletePhone = ValueKey('athletePhone');
const kAthleteWeight = ValueKey('athleteWeight');
const kAthleteHeight = ValueKey('athleteHeight');
const kAthleteMembership = ValueKey('athleteMembership');
const kSaveAthleteButton = ValueKey('saveAthleteButton');
const kAthleteValidationError = ValueKey('athleteValidationError');
const kAthleteSearch = ValueKey('athleteSearch');
const kEditAthleteButton = ValueKey('editAthleteButton');
const kDeleteAthleteButton = ValueKey('deleteAthleteButton');
const kConfirmDeleteButton = ValueKey('confirmDeleteButton');
const kSuccessMessage = ValueKey('successMessage');

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('No se encontró el widget: $finder');
}

Future<void> startApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await pumpUntilFound(tester, find.byKey(kLoginEmail));
}

Future<void> loginAsAdmin(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(kLoginEmail),
    TestConfig.adminEmail,
  );
  await tester.enterText(
    find.byKey(kLoginPassword),
    TestConfig.adminPassword,
  );
  await tester.tap(find.byKey(kLoginButton));

  await pumpUntilFound(tester, find.byKey(kAdminDashboard));
  expect(find.byKey(kAdminDashboard), findsOneWidget);
}

Future<void> openAthletes(WidgetTester tester) async {
  await tester.tap(find.byKey(kAthletesMenu));
  await pumpUntilFound(tester, find.byKey(kNewAthleteButton));
}

Future<void> chooseMembership(WidgetTester tester) async {
  await tester.tap(find.byKey(kAthleteMembership));
  await tester.pumpAndSettle();

  final option = find.text(TestConfig.membershipName).last;
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<String> fillValidAthlete(
  WidgetTester tester, {
  String prefix = 'flutter',
}) async {
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = '$prefix.$stamp@ironcladbox.test';

  await tester.enterText(find.byKey(kAthleteName), 'Atleta');
  await tester.enterText(find.byKey(kAthleteLastname), 'Prueba $stamp');
  await tester.enterText(find.byKey(kAthleteEmail), email);
  await tester.enterText(find.byKey(kAthletePhone), '0991234567');
  await tester.enterText(find.byKey(kAthleteWeight), '70');
  await tester.enterText(find.byKey(kAthleteHeight), '1.75');
  await chooseMembership(tester);

  return email;
}

Future<String> createAthlete(
  WidgetTester tester, {
  String prefix = 'flutter',
}) async {
  await tester.tap(find.byKey(kNewAthleteButton));
  await tester.pumpAndSettle();

  final email = await fillValidAthlete(tester, prefix: prefix);
  await tester.tap(find.byKey(kSaveAthleteButton));

  await pumpUntilFound(tester, find.byKey(kSuccessMessage));
  expect(find.byKey(kSuccessMessage), findsOneWidget);
  return email;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IronCladBox móvil — pruebas integradas', () {
    testWidgets('CP-MOB-01: inicio de sesión válido', (tester) async {
      await startApp(tester);
      await loginAsAdmin(tester);
    });

    testWidgets('CP-MOB-02: credenciales incorrectas', (tester) async {
      await startApp(tester);

      await tester.enterText(
        find.byKey(kLoginEmail),
        'usuario.inexistente@ironcladbox.test',
      );
      await tester.enterText(
        find.byKey(kLoginPassword),
        'ClaveIncorrecta123_',
      );
      await tester.tap(find.byKey(kLoginButton));

      await pumpUntilFound(tester, find.byKey(kLoginError));
      expect(find.byKey(kLoginError), findsOneWidget);
      expect(find.byKey(kAdminDashboard), findsNothing);
    });

    testWidgets('CP-MOB-03: campos de login obligatorios', (tester) async {
      await startApp(tester);

      await tester.tap(find.byKey(kLoginButton));
      await tester.pumpAndSettle();

      expect(find.byKey(kLoginError), findsWidgets);
      expect(find.byKey(kAdminDashboard), findsNothing);
    });

    testWidgets('CP-MOB-04: registra un atleta válido', (tester) async {
      await startApp(tester);
      await loginAsAdmin(tester);
      await openAthletes(tester);

      final email = await createAthlete(tester, prefix: 'crear');
      await pumpUntilFound(tester, find.text(email));

      expect(find.text(email), findsOneWidget);
    });

    testWidgets('CP-MOB-05: rechaza datos inválidos del atleta', (tester) async {
      await startApp(tester);
      await loginAsAdmin(tester);
      await openAthletes(tester);

      await tester.tap(find.byKey(kNewAthleteButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(kAthleteEmail), 'correo-invalido');
      await tester.enterText(find.byKey(kAthletePhone), '123');
      await tester.enterText(find.byKey(kAthleteWeight), '-1');
      await tester.enterText(find.byKey(kAthleteHeight), '0');
      await tester.tap(find.byKey(kSaveAthleteButton));
      await tester.pumpAndSettle();

      expect(find.byKey(kAthleteValidationError), findsWidgets);
      expect(find.byKey(kSuccessMessage), findsNothing);
    });

    testWidgets('CP-MOB-06: edita un atleta', (tester) async {
      await startApp(tester);
      await loginAsAdmin(tester);
      await openAthletes(tester);

      final email = await createAthlete(tester, prefix: 'editar');
      await pumpUntilFound(tester, find.text(email));

      await tester.enterText(find.byKey(kAthleteSearch), email);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(kEditAthleteButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(kAthletePhone), '0987654321');
      await tester.tap(find.byKey(kSaveAthleteButton));

      await pumpUntilFound(tester, find.byKey(kSuccessMessage));
      expect(find.byKey(kSuccessMessage), findsOneWidget);
    });

    testWidgets('CP-MOB-07: elimina un atleta con confirmación', (tester) async {
      await startApp(tester);
      await loginAsAdmin(tester);
      await openAthletes(tester);

      final email = await createAthlete(tester, prefix: 'eliminar');
      await pumpUntilFound(tester, find.text(email));

      await tester.enterText(find.byKey(kAthleteSearch), email);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(kDeleteAthleteButton));

      await pumpUntilFound(tester, find.byKey(kConfirmDeleteButton));
      await tester.tap(find.byKey(kConfirmDeleteButton));
      await tester.pumpAndSettle();

      expect(find.text(email), findsNothing);
    });
  });
}
