import 'package:flutter/material.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/menu.dart';
import 'package:pie_menu/src/button.dart';

/// Defines the behavior and the appearance
/// of the [PieCanvas] and [PieMenu] widgets.
class PieTheme {
  /// Creates a [PieTheme] to configure [PieMenu]s.
  const PieTheme({
    this.brightness = Brightness.light,
    this.overlayColor,
    this.pointerColor,
    this.buttonTheme = const PieButtonTheme(),
    this.hoveredButtonTheme = const PieButtonTheme.hovered(),
    this.iconSize,
    this.distance = 96,
    this.buttonSize = 56,
    this.pointerSize = 42,
    this.tooltipPadding = 32,
    this.tooltipStyle,
    this.bounceDuration = const Duration(seconds: 1),
    this.fadeDuration = const Duration(milliseconds: 250),
    this.hoverDuration = const Duration(milliseconds: 250),
    this.delayDuration = const Duration(milliseconds: 500),
  });

  /// How the background and tooltip texts should be displayed
  /// if they are not specified explicitly.
  final Brightness brightness;

  /// Preferably a translucent color for [PieCanvas] to display
  /// under the menu child, and on top of the other widgets.
  final Color? overlayColor;

  /// Color of the widget displayed in the center of the [PieMenu].
  final Color? pointerColor;

  /// Theme of the [PieButton].
  final PieButtonTheme buttonTheme;

  /// Theme of the [PieButton] when it is hovered.
  final PieButtonTheme hoveredButtonTheme;

  /// Size of the icon to be displayed on the [PieButton].
  final double? iconSize;

  /// Distance between the [PieButton] and the center of the [PieMenu].
  final double distance;

  /// Size of the [PieButton] circle.
  final double buttonSize;

  /// Size of the widget displayed in the center of the [PieMenu].
  final double pointerSize;

  /// Padding value of the tooltip at the edges of the [PieCanvas].
  final double tooltipPadding;

  /// Style of the tooltip text.
  final TextStyle? tooltipStyle;

  /// Duration of the [PieButton] bounce animation.
  final Duration bounceDuration;

  /// Duration of the [PieMenu] fade animation.
  final Duration fadeDuration;

  /// Duration of the [PieButton] hover animation.
  final Duration hoverDuration;

  /// Long press duration for [PieMenu] to display.
  ///
  /// Can be set to [Duration.zero] to display the menu immediately
  /// after pressing the menu child.
  final Duration delayDuration;

  /// Displacement distance of the [PieButton]s when hovered.
  double get hoverDisplacement => buttonSize / 8;

  /// Creates a copy of this theme but with the
  /// given fields replaced with the new values.
  PieTheme copyWith({
    Brightness? brightness,
    Color? overlayColor,
    Color? pointerColor,
    PieButtonTheme? buttonTheme,
    PieButtonTheme? hoveredButtonTheme,
    double? distance,
    double? buttonSize,
    double? pointerSize,
    double? tooltipPadding,
    TextStyle? tooltipStyle,
    Duration? bounceDuration,
    Duration? fadeDuration,
    Duration? hoverDuration,
    Duration? delayDuration,
  }) {
    return PieTheme(
      brightness: brightness ?? this.brightness,
      overlayColor: overlayColor ?? this.overlayColor,
      pointerColor: pointerColor ?? this.pointerColor,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      hoveredButtonTheme: hoveredButtonTheme ?? this.hoveredButtonTheme,
      distance: distance ?? this.distance,
      buttonSize: buttonSize ?? this.buttonSize,
      pointerSize: pointerSize ?? this.pointerSize,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipStyle: tooltipStyle ?? this.tooltipStyle,
      bounceDuration: bounceDuration ?? this.bounceDuration,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      delayDuration: delayDuration ?? this.delayDuration,
    );
  }
}

/// Defines the appearance of the [PieButton]s.
class PieButtonTheme {
  const PieButtonTheme({
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.decoration,
  });

  /// Creates a [PieButtonTheme] with the hovered style defaults.
  const PieButtonTheme.hovered({
    this.backgroundColor = Colors.lime,
    this.iconColor = Colors.black,
    this.decoration,
  });

  /// Background color of the [PieButton].
  final Color? backgroundColor;

  /// Icon color of the [PieButton].
  final Color? iconColor;

  /// Container decoration of the [PieButton].
  ///
  /// Note that a custom decoration ignores [backgroundColor].
  final Decoration? decoration;
}
