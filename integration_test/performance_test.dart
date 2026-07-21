import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ironcladbox_movil/main.dart' as app;
import 'test_config.dart';

const kLoginEmail = ValueKey('loginEmail');
const kLoginPassword = ValueKey('loginPassword');
const kLoginButton = ValueKey('loginButton');
const kAdminDashboard = ValueKey('adminDashboard');
const kAthletesMenu = ValueKey('athletesMenu');
const kAthleteList = ValueKey('athleteList');

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('No se encontró el widget: $finder');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PR-MOB-01: mide fluidez al desplazar la lista de atletas',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byKey(kLoginEmail), TestConfig.adminEmail);
    await tester.enterText(
      find.byKey(kLoginPassword),
      TestConfig.adminPassword,
    );
    await tester.tap(find.byKey(kLoginButton));
    await pumpUntilFound(tester, find.byKey(kAdminDashboard));

    await tester.tap(find.byKey(kAthletesMenu));
    await pumpUntilFound(tester, find.byKey(kAthleteList));

    final list = find.byKey(kAthleteList);

    await binding.traceAction(() async {
      for (var i = 0; i < 8; i++) {
        await tester.fling(list, const Offset(0, -500), 1200);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 8; i++) {
        await tester.fling(list, const Offset(0, 500), 1200);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'athlete_list_scrolling');
  });
}
