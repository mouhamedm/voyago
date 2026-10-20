import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyago/features/auth/login_screen.dart';
import 'package:voyago/features/flights/flight_results_screen.dart';
import 'package:voyago/features/home/home_screen.dart';
import 'package:voyago/features/intro/welcome_screen.dart';
import 'package:voyago/main.dart';

Future<void> pumpFlow(WidgetTester tester, {int steps = 12, Duration stepDuration = const Duration(milliseconds: 200)}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(stepDuration);
  }
}

void main() {
  testWidgets('App boots on WelcomeScreen (Screen 1) with branding and Commencer CTA', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('VOYAGO'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('Tap Commencer triggers spinner and transitions to LoginScreen', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Tap Commencer
    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12); // 2.4s total, advancing all sequential animations and timers

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Bienvenue sur Voyago'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('Empty fields trigger validation error and do not navigate', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap Continuer while fields are empty
    final continuerFinder = find.text('Continuer');
    await tester.ensureVisible(continuerFinder);
    await tester.tap(continuerFinder);
    await pumpFlow(tester, steps: 4);

    expect(find.text('Veuillez remplir tous les champs obligatoires'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('Switching to Inscription shows Nom et prénom field', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    await tester.tap(find.text('Inscription'));
    await pumpFlow(tester, steps: 3);

    expect(find.text('Nom et prénom'), findsOneWidget);
  });

  testWidgets('From LoginScreen, filling credentials accesses HomeScreen (Screen 2)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    expect(find.byType(LoginScreen), findsOneWidget);

    // Enter credentials
    await tester.enterText(find.byType(TextField).at(0), 'mouhamed@voyago.app');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await pumpFlow(tester, steps: 2);

    // Tap Continuer
    final continuerFinder = find.text('Continuer');
    await tester.ensureVisible(continuerFinder);
    await tester.tap(continuerFinder);
    await pumpFlow(tester, steps: 24); // 4.8s total to cover auth choreography

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Rechercher un vol'), findsOneWidget);
    expect(find.text('Destinations populaires'), findsOneWidget);
  });

  testWidgets('Tap Rechercher un vol opens FlightResultsScreen (Screen 3)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    // Tap Passer button at top right
    final passerFinder = find.text('Passer');
    await tester.tap(passerFinder);
    await pumpFlow(tester, steps: 6);

    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Rechercher un vol
    await tester.tap(find.text('Rechercher un vol'));
    await pumpFlow(tester, steps: 6);

    expect(find.byType(FlightResultsScreen), findsOneWidget);
    expect(find.text('AIRFRANCE'), findsOneWidget);
    expect(find.text('Royal Air Maroc'), findsOneWidget);
  });

  testWidgets('Replay signal resets to WelcomeScreen', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    final passerFinder = find.text('Passer');
    await tester.tap(passerFinder);
    await pumpFlow(tester, steps: 6);
    expect(find.byType(HomeScreen), findsOneWidget);

    kReplaySignal.value++;
    await pumpFlow(tester, steps: 6);

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}

