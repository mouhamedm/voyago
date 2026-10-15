import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyago/main.dart';
import 'package:voyago/features/home/home_screen.dart';

Future<void> _pumpFrames(WidgetTester tester, Duration total, {Duration step = const Duration(milliseconds: 100)}) async {
  var elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.pump(step);
    elapsed += step;
  }
}

void main() {
  testWidgets('Full intro flow: preloader -> welcome -> login -> home', (tester) async {
    await tester.pumpWidget(const VoyagoApp());

    // Preloader (3.2s) + crossfade (0.4s) vers Welcome.
    await _pumpFrames(tester, const Duration(milliseconds: 4000));
    expect(find.text('Commencer'), findsOneWidget);

    // Tap "Commencer" -> transition vers Login (900ms).
    await tester.tap(find.text('Commencer'));
    await _pumpFrames(tester, const Duration(milliseconds: 1200));
    expect(find.text('Bon retour'), findsOneWidget);

    // Remplir le formulaire.
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@voyago.app');
    await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), 'password123');
    await tester.pump();

    // Tap "Accéder" -> chorégraphie d'ouverture (2.4s) + reveal (0.9s) + home (0.3s).
    await tester.tap(find.text('Accéder'));
    await _pumpFrames(tester, const Duration(milliseconds: 4200));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Salut, Alex'), findsOneWidget);
  });

  testWidgets('Invalid credentials trigger field errors instead of opening sequence', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await _pumpFrames(tester, const Duration(milliseconds: 4000));

    await tester.tap(find.text('Commencer'));
    await _pumpFrames(tester, const Duration(milliseconds: 1200));

    await tester.tap(find.text('Accéder'));
    await _pumpFrames(tester, const Duration(milliseconds: 500));

    expect(find.text('Entrez votre email'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('Debug replay signal resets the flow back to the preloader', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await _pumpFrames(tester, const Duration(milliseconds: 4000));
    expect(find.text('Commencer'), findsOneWidget);

    kReplaySignal.value++;
    await tester.pump();

    expect(find.text('Commencer'), findsNothing);

    await _pumpFrames(tester, const Duration(milliseconds: 4000));
    expect(find.text('Commencer'), findsOneWidget);
  });
}
