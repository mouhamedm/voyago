import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voyago/main.dart';

void main() {
  testWidgets('App boots on the preloader without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const VoyagoApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
