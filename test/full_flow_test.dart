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
    expect(find.text('Bon retour,'), findsOneWidget);
    expect(find.text('Accéder'), findsOneWidget);
  });

  testWidgets('From LoginScreen, login accesses HomeScreen (Screen 2)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap Accéder
    final accederFinder = find.text('Accéder');
    await tester.ensureVisible(accederFinder);
    await tester.tap(accederFinder);
    await pumpFlow(tester, steps: 24); // 4.8s total to cover 3.44s auth choreography

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Rechercher un vol'), findsOneWidget);
    expect(find.text('Destinations populaires'), findsOneWidget);
  });

  testWidgets('Tap Rechercher un vol opens FlightResultsScreen (Screen 3)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await pumpFlow(tester, steps: 12);

    // Guest login to jump to HomeScreen
    final guestFinder = find.text('Explorer l\'application en tant qu\'invité →');
    await tester.ensureVisible(guestFinder);
    await tester.tap(guestFinder);
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

    final guestFinder = find.text('Explorer l\'application en tant qu\'invité →');
    await tester.ensureVisible(guestFinder);
    await tester.tap(guestFinder);
    await pumpFlow(tester, steps: 6);
    expect(find.byType(HomeScreen), findsOneWidget);

    kReplaySignal.value++;
    await pumpFlow(tester, steps: 6);

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}

