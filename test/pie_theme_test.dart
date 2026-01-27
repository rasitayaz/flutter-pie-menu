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
      const theme = PieTheme();
      final newTheme = theme.copyWith(
        brightness: Brightness.dark,
        overlayColor: Colors.purple,
        pointerColor: Colors.yellow,
        pointerDecoration: const BoxDecoration(color: Colors.red),
        buttonTheme: const PieButtonTheme(
          backgroundColor: Colors.red,
          iconColor: Colors.black,
        ),
        buttonThemeHovered: const PieButtonTheme(
          backgroundColor: Colors.orange,
          iconColor: Colors.white,
        ),
        iconSize: 30,
        radius: 120,
        spacing: 15,
        customAngleDiff: 45,
        angleOffset: 90,
        customAngle: 180,
        customAngleAnchor: PieAnchor.start,
        menuAlignment: Alignment.topCenter,
        menuDisplacement: const Offset(10, 10),
        buttonSize: 60,
        pointerSize: 50,
        tooltipPadding: const EdgeInsets.all(10),
        tooltipTextStyle: const TextStyle(fontSize: 20),
        tooltipTextAlign: TextAlign.right,
        tooltipCanvasAlignment: Alignment.bottomRight,
        tooltipUseFittedBox: true,
        pieBounceDuration: const Duration(seconds: 2),
        childBounceEnabled: false,
        childTiltEnabled: false,
        childBounceDuration: const Duration(seconds: 3),
        childBounceDistance: 0.5, // Maps to childBounceFactor
        childBounceCurve: Curves.linear,
        childBounceReverseCurve: Curves.bounceIn,
        childBounceFilterQuality: FilterQuality.high,
        fadeDuration: const Duration(seconds: 4),
        hoverDuration: const Duration(seconds: 5),
        longPressDuration: const Duration(seconds: 6),
        regularPressShowsMenu: true,
        longPressShowsMenu: false,
        leftClickShowsMenu: false,
        rightClickShowsMenu: true,
        overlayStyle: PieOverlayStyle.around,
        childOpacityOnButtonHover: 0.1,
      );

      expect(newTheme.brightness, Brightness.dark);
      expect(newTheme.overlayColor, Colors.purple);
      expect(newTheme.pointerColor, Colors.yellow);
      expect((newTheme.pointerDecoration as BoxDecoration).color, Colors.red);
      expect(newTheme.buttonTheme.backgroundColor, Colors.red);
      expect(newTheme.buttonThemeHovered.backgroundColor, Colors.orange);
      expect(newTheme.iconSize, 30);
      expect(newTheme.radius, 120);
      expect(newTheme.spacing, 15);
      expect(newTheme.customAngleDiff, 45);
      expect(newTheme.angleOffset, 90);
      expect(newTheme.customAngle, 180);
      expect(newTheme.customAngleAnchor, PieAnchor.start);
      expect(newTheme.menuAlignment, Alignment.topCenter);
      expect(newTheme.menuDisplacement, const Offset(10, 10));
      expect(newTheme.buttonSize, 60);
      expect(newTheme.pointerSize, 50);
      expect(newTheme.tooltipPadding, const EdgeInsets.all(10));
      expect(newTheme.tooltipTextStyle?.fontSize, 20);
      expect(newTheme.tooltipTextAlign, TextAlign.right);
      expect(newTheme.tooltipCanvasAlignment, Alignment.bottomRight);
      expect(newTheme.tooltipUseFittedBox, true);
      expect(newTheme.pieBounceDuration, const Duration(seconds: 2));
      expect(newTheme.childBounceEnabled, false);
      expect(newTheme.childTiltEnabled, false);
      expect(newTheme.childBounceDuration, const Duration(seconds: 3));
      expect(
          newTheme.childBounceFactor, 0.5); // Derived from childBounceDistance
      expect(newTheme.childBounceCurve, Curves.linear);
      expect(newTheme.childBounceReverseCurve, Curves.bounceIn);
      expect(newTheme.childBounceFilterQuality, FilterQuality.high);
      expect(newTheme.fadeDuration, const Duration(seconds: 4));
      expect(newTheme.hoverDuration, const Duration(seconds: 5));
      expect(newTheme.longPressDuration, const Duration(seconds: 6));
      expect(newTheme.regularPressShowsMenu, true);
      expect(newTheme.longPressShowsMenu, false);
      expect(newTheme.leftClickShowsMenu, false);
      expect(newTheme.rightClickShowsMenu, true);
      expect(newTheme.overlayStyle, PieOverlayStyle.around);
      expect(newTheme.childOpacityOnButtonHover, 0.1);
    });

    test('copyWith respects deprecated delayDuration', () {
      const theme = PieTheme();
      // ignore: deprecated_member_use_from_same_package
      final newTheme =
          theme.copyWith(delayDuration: const Duration(seconds: 1));
      expect(newTheme.longPressDuration, const Duration(seconds: 1));
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
