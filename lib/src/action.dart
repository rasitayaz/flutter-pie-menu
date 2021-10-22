import 'package:flutter/material.dart';
import 'package:pie_menu/src/button.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/menu.dart';

/// Action class to create different [PieButton]s for the [PieMenu].
class PieAction {
  PieAction({
    required this.tooltip,
    required this.onSelect,
    this.iconData,
    this.iconSize,
    this.padding = EdgeInsets.zero,
    this.customWidget,
    this.customHoveredWidget,
    this.color,
    this.iconColor,
    this.hoveredColor,
    this.hoveredIconColor,
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

  /// Background color of the [PieButton] to override the theme color.
  final Color? color;

  /// Icon color of the [PieButton] to override the theme color.
  final Color? iconColor;

  /// Background color of the [PieButton] to override the theme color
  /// when it is hovered by the user.
  final Color? hoveredColor;

  /// Icon color of the [PieButton] to override the theme color
  /// when it is hovered by the user.
  final Color? hoveredIconColor;

  /// Display angle of the [PieButton] in radians.
  ///
  /// This is assigned after all [PieAction]s have been processed.
  double angle = 0;
}
