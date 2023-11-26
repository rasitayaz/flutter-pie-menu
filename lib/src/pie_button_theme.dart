import 'package:flutter/widgets.dart';

/// Defines the appearance of the circular buttons.
class PieButtonTheme {
  const PieButtonTheme({
    required this.backgroundColor,
    required this.iconColor,
    this.decoration,
  });

  /// Background color of the button.
  final Color? backgroundColor;

  /// Icon color of the button.
  final Color? iconColor;

  /// Container decoration of the button.
  ///
  /// Be aware that a custom decoration will ignore [backgroundColor].
  final Decoration? decoration;
}
