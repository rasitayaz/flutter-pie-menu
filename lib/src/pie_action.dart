import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_button_theme.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';

/// Data of a circular button that will be displayed for the [PieMenu].
class PieAction {
  /// Creates a [PieAction] with a child widget.
  ///
  /// It is recommended to use [PieAction.builder] if you want to provide
  /// a custom widget instead of an icon.
  PieAction({
    required this.tooltip,
    required this.onSelect,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.child,
  })  : builder = null,
        subActions = null,
        isSubmenu = false;

  /// Creates a [PieAction] with a builder which provides
  /// whether the action is hovered or not as a parameter.
  PieAction.builder({
    required this.tooltip,
    required this.onSelect,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.builder,
  })  : child = null,
        subActions = null,
        isSubmenu = false;

  /// Creates a [PieAction] that opens a submenu when selected.
  ///
  /// Instead of triggering an action when selected, this will open
  /// a nested menu with the provided [subActions] centered around this action.
  PieAction.submenu({
    required this.tooltip,
    required List<PieAction> submenuActions,
    this.buttonTheme,
    this.buttonThemeHovered,
    required this.child,
    Function()? onSelectAction,
  })  : builder = null,
        onSelect = onSelectAction ?? (() {}),
        subActions = submenuActions,
        isSubmenu = true;

  /// Widget to display on [PieCanvas] when this action is hovered.
  final Widget tooltip;

  /// Function to trigger when [PieButton] is selected.
  ///
  /// You can select an action either by dragging your finger
  /// over it and releasing or by simply pressing on it.
  final Function() onSelect;

  /// Button theme to use for idle state.
  final PieButtonTheme? buttonTheme;

  /// Button theme to use for hovered state.
  final PieButtonTheme? buttonThemeHovered;

  /// Widget to display inside [PieButton], usually an icon.
  ///
  /// If this is an icon, its theme can be customized easily
  /// using [buttonTheme] and [buttonThemeHovered].
  final Widget? child;

  /// Widget builder which provides whether the action is hovered or not
  /// as a parameter.
  ///
  /// Useful for custom widgets instead of icons.
  final Widget Function(bool hovered)? builder;

  /// List of actions to display in the submenu when this action is selected.
  ///
  /// Only applicable for submenu actions created with [PieAction.submenu].
  final List<PieAction>? subActions;

  /// Whether this action opens a submenu when selected.
  ///
  /// If true, [onSelect] will be ignored and a submenu will be displayed
  /// when this action is selected, centered around this action.
  final bool isSubmenu;
}
