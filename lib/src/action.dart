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
    this.iconData,
    this.iconSize,
    this.padding = EdgeInsets.zero,
    this.customWidget,
    this.customHoveredWidget,
    this.buttonTheme,
    this.hoveredButtonTheme,
  });

  /// * [PieButton] refers to the button this [PieAction] belongs to.

  /// Text to display on the [PieCanvas] when the [PieButton] is hovered.
  final String tooltip;

  /// Function to trigger when the [PieButton] is selected.
  final Function() onSelect;

  /// Data for the icon to be displayed on the [PieButton].
  final IconData? iconData;

  /// Size of the icon to be displayed on the [PieButton].
  final double? iconSize;

  /// Padding for the icon (or for the custom widget)
  /// to be displayed on the [PieButton].
  ///
  /// Can be used for optical correction.
  final EdgeInsets padding;

  /// Custom widget to display on the [PieButton] instead of the icon.
  final Widget? customWidget;

  /// Custom widget to display on the [PieButton] instead of the icon
  /// when the button is hovered.
  final Widget? customHoveredWidget;

  /// Theme of the [PieButton].
  final PieButtonTheme? buttonTheme;

  /// Theme of the [PieButton] when it is hovered.
  final PieButtonTheme? hoveredButtonTheme;

  /// Display angle of the [PieButton] in radians.
  ///
  /// This is assigned after all [PieAction]s have been processed.
  double angle = 0;
}
