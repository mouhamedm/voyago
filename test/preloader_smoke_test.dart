import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyago/core/theme_config.dart';
import 'package:voyago/features/intro/preloader_screen.dart';

void main() {
  testWidgets('PreloaderScreen runs full 3.2s sequence without throwing', (tester) async {
    var completed = false;
    await tester.pumpWidget(MaterialApp(
      home: PreloaderScreen(
        config: ThemeConfig.current,
        onComplete: () => completed = true,
      ),
    ));

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(completed, isTrue);
  });
}
