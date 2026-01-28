import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  group(PieTheme, () {
    test('effectiveOverlayColor returns correct color based on brightness', () {
      const lightTheme = PieTheme(brightness: Brightness.light);
      expect(lightTheme.effectiveOverlayColor, Colors.white.withOpacity(0.8));

      const darkTheme = PieTheme(brightness: Brightness.dark);
      expect(darkTheme.effectiveOverlayColor, Colors.black.withOpacity(0.8));

      const customTheme = PieTheme(overlayColor: Colors.red);
      expect(customTheme.effectiveOverlayColor, Colors.red);
    });

    test('copyWith creates a new instance with updated values', () {
      const theme = PieTheme(brightness: Brightness.light, radius: 100);
      final newTheme1 = theme.copyWith(brightness: Brightness.dark);
      final newTheme2 = theme.copyWith(radius: 200);

      expect(newTheme1.brightness, Brightness.dark);
      expect(newTheme1.radius, 100);
      expect(newTheme2.brightness, Brightness.light);
      expect(newTheme2.radius, 200);
    });

    testWidgets('of(context) returns the theme from the nearest PieCanvas', (
      tester,
    ) async {
      const customTheme = PieTheme(radius: 200);

      late PieTheme retrievedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: customTheme,
            child: Builder(
              builder: (context) {
                retrievedTheme = PieTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedTheme.radius, 200);
    });
  });
}
