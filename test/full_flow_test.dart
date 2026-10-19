import 'package:flutter_test/flutter_test.dart';
import 'package:voyago/features/flights/flight_results_screen.dart';
import 'package:voyago/features/home/home_screen.dart';
import 'package:voyago/features/intro/welcome_screen.dart';
import 'package:voyago/main.dart';

void main() {
  testWidgets('App boots on WelcomeScreen (Screen 1) with branding and Commencer CTA', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('VOYAGO'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('Tap Commencer transitions to HomeScreen (Screen 2)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Tap Commencer
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Rechercher un vol'), findsOneWidget);
    expect(find.text('Destinations populaires'), findsOneWidget);
  });

  testWidgets('Tap Rechercher un vol opens FlightResultsScreen (Screen 3)', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    // Tap Rechercher un vol
    await tester.tap(find.text('Rechercher un vol'));
    await tester.pumpAndSettle();

    expect(find.byType(FlightResultsScreen), findsOneWidget);
    expect(find.text('AIRFRANCE'), findsOneWidget);
    expect(find.text('Royal Air Maroc'), findsOneWidget);
  });

  testWidgets('Replay signal resets to WelcomeScreen', (tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    kReplaySignal.value++;
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
