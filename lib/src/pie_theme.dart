import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_animation_theme.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_button_theme.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';

/// Action display anchor point for the specified custom angle in [PieTheme].
enum PieAnchor { start, center, end }

/// Decides how to display the translucent canvas overlay.
enum PieOverlayStyle {
  /// Displays the overlay to cover the entire canvas,
  /// and re-renders the menu child on top of the overlay.
  ///
  /// This is the recommended style if your menu child is stateless.
  behind,

  /// Draws the overlay around the menu child using [CustomPainter].
  ///
  /// Use this style if you want to preserve the state of your menu child.
  /// You might experience some rendering issues when the menu is partially
  /// obscured by other widgets.
  around;
}

/// Defines the behavior and the appearance
/// of [PieCanvas] and [PieMenu] widgets.
class PieTheme {
  /// Creates a [PieTheme] to configure [PieMenu]s.
  const PieTheme({
    this.brightness = Brightness.light,
    this.overlayColor,
    this.pointerColor,
    this.pointerDecoration,
    this.buttonTheme = const PieButtonTheme(
      backgroundColor: Colors.blue,
      iconColor: Colors.white,
    ),
    this.buttonThemeHovered = const PieButtonTheme(
      backgroundColor: Colors.green,
      iconColor: Colors.white,
    ),
    this.animationTheme = const PieAnimationTheme(),
    this.iconSize,
    this.radius = 96,
    this.spacing = 6,
    this.customAngleDiff,
    this.angleOffset = 0,
    this.customAngle,
    this.customAngleAnchor = PieAnchor.center,
    this.menuAlignment,
    this.menuDisplacement = Offset.zero,
    this.buttonSize = 56,
    this.pointerSize = 40,
    this.tooltipPadding = const EdgeInsets.all(32),
    this.tooltipTextStyle,
    this.tooltipTextAlign,
    this.tooltipCanvasAlignment,
    this.tooltipUseFittedBox = false,
    this.fadeDuration = const Duration(milliseconds: 250),
    this.hoverDuration = const Duration(milliseconds: 250),
    @Deprecated(
      "Deprecated in favor of 'regularPressShowsMenu', 'longPressShowsMenu' and 'longPressDuration'",
    )
    Duration? delayDuration,
    Duration longPressDuration = const Duration(milliseconds: 350),
    this.regularPressShowsMenu = false,
    this.longPressShowsMenu = true,
    this.leftClickShowsMenu = true,
    this.rightClickShowsMenu = false,
    this.overlayStyle = PieOverlayStyle.behind,
    this.childOpacityOnButtonHover = 0.5,
  }) : longPressDuration = delayDuration ?? longPressDuration;

  /// How the background and tooltip widgets should be displayed
  /// if they are not specified explicitly.
  final Brightness brightness;

  /// Preferably a translucent color for [PieCanvas] to display
  /// under the menu child, and on top of the other widgets.
  final Color? overlayColor;

  /// Custom color for the widget displayed in the center of [PieMenu].
  final Color? pointerColor;

  /// Decoration for the widget displayed in the center of [PieMenu].
  ///
  /// If specified, [pointerColor] will be ignored.
  final Decoration? pointerDecoration;

  /// Theme of [PieButton].
  final PieButtonTheme buttonTheme;

  /// Theme of [PieButton] when it is hovered.
  final PieButtonTheme buttonThemeHovered;

  /// Theme of animation of [PieMenu] and its children.
  final PieAnimationTheme animationTheme;

  /// Size of the icon to be displayed on the [PieButton].
  final double? iconSize;

  /// Distance between the [PieButton] and the center of [PieMenu].
  final double radius;

  /// Spacing between the [PieButton]s.
  final double spacing;

  /// Angle difference between the [PieButton]s in degrees.
  ///
  /// If specified, [spacing] will be ignored.
  final double? customAngleDiff;

  /// Angle offset in degrees for the actions.
  final double angleOffset;

  /// Display the menu actions in a specific angle in degrees.
  final double? customAngle;

  /// Action display alignment for the specified [customAngle].
  final PieAnchor customAngleAnchor;

  /// Alignment of the menu relative to the menu child.
  ///
  /// Can be used to display the menu at a specific position
  /// regardless of the pressed offset.
  /// For example, you can set it to [Alignment.center] to align
  /// the menu at the center of the child widget.
  /// You can combine it with [menuDisplacement] to fine-tune the position.
  final Alignment? menuAlignment;

  /// Displacement offset for the menu.
  final Offset menuDisplacement;

  /// Size of [PieButton] circle.
  final double buttonSize;

  /// Size of the widget displayed in the center of [PieMenu].
  final double pointerSize;

  /// Padding value of the tooltip at the edges of [PieCanvas].
  final EdgeInsets tooltipPadding;

  /// Default text style for the tooltip widget.
  final TextStyle? tooltipTextStyle;

  /// Text alignment of the tooltip widget.
  final TextAlign? tooltipTextAlign;

  /// Alignment of the tooltip in the [PieCanvas].
  ///
  /// Setting this property will disable dynamic tooltip positioning.
  final Alignment? tooltipCanvasAlignment;

  /// Whether to wrap the tooltip with [FittedBox] widget.
  ///
  /// Can be used to display long tooltip texts in a single line.
  final bool tooltipUseFittedBox;

  /// Duration of [PieMenu] fade animation.
  final Duration fadeDuration;

  /// Duration of [PieButton] hover animation.
  final Duration hoverDuration;

  /// Duration of long press gesture to display the menu.
  final Duration longPressDuration;

  /// Whether to display the menu on regular press.
  final bool regularPressShowsMenu;

  /// Whether to display the menu on long press.
  final bool longPressShowsMenu;

  /// Whether to display the menu on left mouse click.
  final bool leftClickShowsMenu;

  /// Whether to display the menu on right mouse click.
  final bool rightClickShowsMenu;

  /// Decides how to display the translucent canvas overlay.
  ///
  /// [PieOverlayStyle.behind] is the recommended style
  /// if your menu child is stateless.
  ///
  /// Use [PieOverlayStyle.around] if you want to preserve the state of your
  /// menu child. However, you might experience some rendering issues
  /// when the menu is partially obscured by other widgets.
  final PieOverlayStyle overlayStyle;

  /// Opacity of the menu child when a button is hovered.
  final double childOpacityOnButtonHover;

  /// Displacement distance of [PieButton]s when hovered.
  double get hoverDisplacement => buttonSize / 8;

  Color get effectiveOverlayColor {
    return overlayColor ??
        (brightness == Brightness.light ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8));
  }

  /// Returns the [PieTheme] defined in the closest [PieCanvas] instance
  /// that encloses the given context.
  static PieTheme of(BuildContext context) {
    return PieNotifier.of(context).canvas.widget.theme;
  }

  /// Creates a copy of this theme but with the
  /// given fields replaced with the new values.
  PieTheme copyWith({
    Brightness? brightness,
    Color? overlayColor,
    Color? pointerColor,
    Decoration? pointerDecoration,
    PieButtonTheme? buttonTheme,
    PieButtonTheme? buttonThemeHovered,
    double? iconSize,
    double? radius,
    double? spacing,
    double? customAngleDiff,
    double? angleOffset,
    double? customAngle,
    PieAnchor? customAngleAnchor,
    Alignment? menuAlignment,
    Offset? menuDisplacement,
    double? buttonSize,
    double? pointerSize,
    EdgeInsets? tooltipPadding,
    TextStyle? tooltipTextStyle,
    TextAlign? tooltipTextAlign,
    Alignment? tooltipCanvasAlignment,
    bool? tooltipUseFittedBox,
    Duration? fadeDuration,
    Duration? hoverDuration,
    @Deprecated(
      "Deprecated in favor of 'regularPressShowsMenu', 'longPressShowsMenu' and 'longPressDuration'",
    )
    Duration? delayDuration,
    bool? regularPressShowsMenu,
    bool? longPressShowsMenu,
    Duration? longPressDuration,
    bool? leftClickShowsMenu,
    bool? rightClickShowsMenu,
    PieOverlayStyle? overlayStyle,
    double? childOpacityOnButtonHover,
  }) {
    return PieTheme(
      brightness: brightness ?? this.brightness,
      overlayColor: overlayColor ?? this.overlayColor,
      pointerColor: pointerColor ?? this.pointerColor,
      pointerDecoration: pointerDecoration ?? this.pointerDecoration,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      buttonThemeHovered: buttonThemeHovered ?? this.buttonThemeHovered,
      iconSize: iconSize ?? this.iconSize,
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      customAngleDiff: customAngleDiff ?? this.customAngleDiff,
      angleOffset: angleOffset ?? this.angleOffset,
      customAngle: customAngle ?? this.customAngle,
      customAngleAnchor: customAngleAnchor ?? this.customAngleAnchor,
      menuAlignment: menuAlignment ?? this.menuAlignment,
      menuDisplacement: menuDisplacement ?? this.menuDisplacement,
      buttonSize: buttonSize ?? this.buttonSize,
      pointerSize: pointerSize ?? this.pointerSize,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipTextStyle: tooltipTextStyle ?? this.tooltipTextStyle,
      tooltipTextAlign: tooltipTextAlign ?? this.tooltipTextAlign,
      tooltipCanvasAlignment: tooltipCanvasAlignment ?? this.tooltipCanvasAlignment,
      tooltipUseFittedBox: tooltipUseFittedBox ?? this.tooltipUseFittedBox,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      longPressDuration: longPressDuration ?? delayDuration ?? this.longPressDuration,
      regularPressShowsMenu: regularPressShowsMenu ?? this.regularPressShowsMenu,
      longPressShowsMenu: longPressShowsMenu ?? this.longPressShowsMenu,
      leftClickShowsMenu: leftClickShowsMenu ?? this.leftClickShowsMenu,
      rightClickShowsMenu: rightClickShowsMenu ?? this.rightClickShowsMenu,
      overlayStyle: overlayStyle ?? this.overlayStyle,
      childOpacityOnButtonHover: childOpacityOnButtonHover ?? this.childOpacityOnButtonHover,
    );
  }
}
