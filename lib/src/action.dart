import 'package:flutter/material.dart';
import 'package:pie_menu/src/button.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/menu.dart';
import 'package:pie_menu/src/theme.dart';

/// Defines an action to display on the circular buttons of the [PieMenu].
class PieAction {
  PieAction({
    required this.tooltip,
    required this.onSelect,
    required this.child,
    this.childHovered,
    this.padding = EdgeInsets.zero,
    this.buttonTheme,
    this.buttonThemeHovered,
  });

  /// * [PieButton] refers to the button this [PieAction] belongs to.

  /// Text to display on the [PieCanvas] when the [PieButton] is hovered.
  final String tooltip;

  /// Function to trigger when the [PieButton] is selected.
  final Function() onSelect;

  /// Padding for the icon (or for the custom widget)
  /// to be displayed on the [PieButton].
  ///
  /// Can be used for optical correction.
  final EdgeInsets padding;

  /// Widget to display inside the [PieButton], usually an icon
  final Widget child;

  /// Widget to display inside the [PieButton] when the button is hovered.
  final Widget? childHovered;

  /// Theme of the [PieButton].
  final PieButtonTheme? buttonTheme;

  /// Theme of the [PieButton] when it is hovered.
  final PieButtonTheme? buttonThemeHovered;

  /// Display angle of the [PieButton] in radians.
  ///
  /// This is assigned after all [PieAction]s have been processed.
  double angle = 0;
}
