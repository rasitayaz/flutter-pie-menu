import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_button.dart';

/// Defines an action to display on the circular buttons of the [PieMenu].
class PieAction {
  /// Creates a [PieAction] with a child widget.
  ///
  /// It is recommended to use [PieAction.builder] if you want to provide
  /// a custom widget instead of an icon.
  PieAction({
    required this.tooltip,
    required this.onSelect,
    this.padding = EdgeInsets.zero,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.child,
  }) : builder = null;

  /// Creates a [PieAction] with a builder which provides
  /// whether the action is hovered or not.
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

  /// Padding for the child widget displayed on [PieButton].
  ///
  /// Can be used for optical correction.
  final EdgeInsets padding;

  /// Theme of [PieButton].
  final PieButtonTheme? buttonTheme;

  /// Theme of [PieButton] when it is hovered.
  final PieButtonTheme? buttonThemeHovered;

  /// Widget to display inside [PieButton], usually an icon.
  ///
  /// If this is an icon, its theme can be customized easily
  /// using [buttonTheme] and [buttonThemeHovered].
  final Widget? child;

  /// Widget builder which provides whether the action is hovered or not.
  ///
  /// Useful for custom widgets instead of icons.
  final Widget Function(bool hovered)? builder;
}
