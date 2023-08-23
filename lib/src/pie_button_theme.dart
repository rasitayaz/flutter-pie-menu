import 'package:flutter/widgets.dart';
import 'package:pie_menu/src/pie_button.dart';

/// Defines the appearance of the circular buttons.
class PieButtonTheme {
  const PieButtonTheme({
    required this.backgroundColor,
    required this.iconColor,
    this.decoration,
  });

  /// Background color of [PieButton].
  final Color? backgroundColor;

  /// Icon color of [PieButton].
  final Color? iconColor;

  /// Container decoration of [PieButton].
  ///
  /// Note that a custom decoration will ignore [backgroundColor].
  final Decoration? decoration;
}
