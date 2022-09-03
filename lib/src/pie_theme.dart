import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';

/// Defines the behavior and the appearance
/// of the [PieCanvas] and [PieMenu] widgets.
class PieTheme {
  /// Creates a [PieTheme] to configure [PieMenu]s.
  const PieTheme({
    this.bouncingMenu = true,
    this.brightness = Brightness.light,
    this.overlayColor,
    this.pointerColor,
    this.buttonTheme = const PieButtonTheme(
      backgroundColor: Colors.blue,
      iconColor: Colors.white,
    ),
    this.buttonThemeHovered = const PieButtonTheme(
      backgroundColor: Colors.lime,
      iconColor: Colors.black,
    ),
    this.iconSize,
    this.distance = 96,
    this.buttonSize = 56,
    this.pointerSize = 42,
    this.tooltipPadding = const EdgeInsets.symmetric(horizontal: 32),
    this.tooltipStyle,
    this.pieBounceDuration = const Duration(seconds: 1),
    this.menuBounceDuration = const Duration(milliseconds: 150),
    this.menuBounceDepth = 0.95,
    this.menuBounceCurve = Curves.ease,
    this.menuBounceReverseCurve,
    this.fadeDuration = const Duration(milliseconds: 250),
    this.hoverDuration = const Duration(milliseconds: 250),
    this.delayDuration = const Duration(milliseconds: 350),
  });

  final bool bouncingMenu;

  /// How the background and tooltip texts should be displayed
  /// if they are not specified explicitly.
  final Brightness brightness;

  /// Preferably a translucent color for [PieCanvas] to display
  /// under the menu child, and on top of the other widgets.
  final Color? overlayColor;

  /// Color of the widget displayed in the center of [PieMenu].
  final Color? pointerColor;

  /// Theme of [PieButton].
  final PieButtonTheme buttonTheme;

  /// Theme of [PieButton] when it is hovered.
  final PieButtonTheme buttonThemeHovered;

  /// Size of the icon to be displayed on the [PieButton].
  final double? iconSize;

  /// Distance between the [PieButton] and the center of [PieMenu].
  final double distance;

  /// Size of [PieButton] circle.
  final double buttonSize;

  /// Size of the widget displayed in the center of [PieMenu].
  final double pointerSize;

  /// Padding value of the tooltip at the edges of [PieCanvas].
  final EdgeInsets tooltipPadding;

  /// Style of the tooltip text.
  final TextStyle? tooltipStyle;

  /// Duration of [PieButton] bounce animation.
  final Duration pieBounceDuration;

  /// Duration of [PieMenu] bounce animation.
  final Duration menuBounceDuration;

  /// Decides how small the menu child will be when it is bouncing.
  /// A value between 0 and 1.
  final double menuBounceDepth;

  /// Curve for the menu bounce animation.
  final Curve menuBounceCurve;

  /// Reverse curve for the menu bounce animation.
  final Curve? menuBounceReverseCurve;

  /// Duration of [PieMenu] fade animation.
  final Duration fadeDuration;

  /// Duration of [PieButton] hover animation.
  final Duration hoverDuration;

  /// Long press duration for [PieMenu] to display.
  ///
  /// Can be set to [Duration.zero] to display the menu immediately
  /// after pressing the menu child.
  final Duration delayDuration;

  /// Displacement distance of [PieButton]s when hovered.
  double get hoverDisplacement => buttonSize / 8;

  /// Creates a copy of this theme but with the
  /// given fields replaced with the new values.
  PieTheme copyWith({
    Brightness? brightness,
    Color? overlayColor,
    Color? pointerColor,
    PieButtonTheme? buttonTheme,
    PieButtonTheme? buttonThemeHovered,
    double? distance,
    double? buttonSize,
    double? pointerSize,
    EdgeInsets? tooltipPadding,
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
      buttonThemeHovered: buttonThemeHovered ?? this.buttonThemeHovered,
      distance: distance ?? this.distance,
      buttonSize: buttonSize ?? this.buttonSize,
      pointerSize: pointerSize ?? this.pointerSize,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipStyle: tooltipStyle ?? this.tooltipStyle,
      pieBounceDuration: bounceDuration ?? pieBounceDuration,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      delayDuration: delayDuration ?? this.delayDuration,
    );
  }
}

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
  /// Note that a custom decoration ignores [backgroundColor].
  final Decoration? decoration;
}
