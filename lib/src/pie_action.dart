import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_button.dart';

/// Defines an action to display on the circular buttons of the [PieMenu].
class PieAction {
  /// Creates a [PieAction] with a child widget.
  PieAction({
    required this.tooltip,
    required this.onSelect,
    this.padding = EdgeInsets.zero,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.child,
  }) : builder = null;

  /// Creates a [PieAction] with a builder which .
  PieAction.builder({
    required this.tooltip,
    required this.onSelect,
    this.padding = EdgeInsets.zero,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.builder,
  }) : child = null;

  /// * [PieButton] refers to the button this [PieAction] belongs to.

  /// Text to display on [PieCanvas] when [PieButton] is hovered.
  final String tooltip;

  /// Function to trigger when [PieButton] is selected.
  final Function() onSelect;

  /// Padding for the icon (or for the custom widget)
  /// to be displayed on [PieButton].
  ///
  /// Can be used for optical correction.
  final EdgeInsets padding;

  /// Theme of [PieButton].
  final PieButtonTheme? buttonTheme;

  /// Theme of [PieButton] when it is hovered.
  final PieButtonTheme? buttonThemeHovered;

  /// Widget to display inside [PieButton], usually an icon
  final Widget? child;

  /// Widget to display inside [PieButton] when the button is hovered.
  final Widget Function(bool hovered)? builder;
}
