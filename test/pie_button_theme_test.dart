import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  group(PieButtonTheme, () {
    test('properties are set correctly', () {
      const backgroundColor = Colors.red;
      const iconColor = Colors.white;
      const decoration = BoxDecoration(color: Colors.blue);

      const theme = PieButtonTheme(
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        decoration: decoration,
      );

      expect(theme.backgroundColor, backgroundColor);
      expect(theme.iconColor, iconColor);
      expect(theme.decoration, decoration);
    });

    test('properties are set correctly without decoration', () {
      const backgroundColor = Colors.red;
      const iconColor = Colors.white;

      const theme = PieButtonTheme(
        backgroundColor: backgroundColor,
        iconColor: iconColor,
      );

      expect(theme.backgroundColor, backgroundColor);
      expect(theme.iconColor, iconColor);
      expect(theme.decoration, isNull);
    });
  });
}
