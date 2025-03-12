import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

/// Customized [FlowDelegate] to size and position pie actions efficiently.
class PieDelegate extends FlowDelegate {
  PieDelegate({
    required this.bounceAnimation,
    required this.pointerOffset,
    required this.canvasOffset,
    required this.baseAngle,
    required this.angleDiff,
    required this.theme,
  })  : centerOffset = pointerOffset,
        radius = theme.radius,
        applyAngleOffset = true,
        super(repaint: bounceAnimation);

  /// Creates a custom delegate with specific center, radius and angle settings.
  ///
  /// Useful for positioning submenu actions around a different center point with
  /// different radius and angle settings.
  PieDelegate.custom({
    required this.bounceAnimation,
    required this.centerOffset,
    required this.canvasOffset,
    required this.baseAngle,
    required this.angleDiff,
    required this.radius,
    required this.theme,
    this.applyAngleOffset = true,
  })  : pointerOffset = centerOffset,
        super(repaint: bounceAnimation);

  /// Bouncing animation for the buttons.
  final Animation bounceAnimation;

  /// Offset of the widget displayed in the center of the [PieMenu].
  final Offset pointerOffset;

  /// Center point for the pie menu - usually same as pointerOffset
  /// but can be different for submenus.
  final Offset centerOffset;

  /// Offset of the [PieCanvas].
  final Offset canvasOffset;

  /// Angle of the first [PieButton] in degrees.
  final double baseAngle;

  /// Angle difference between the [PieButton]s in degrees.
  final double angleDiff;

  /// Distance between the [PieButton]s and the center point.
  final double radius;

  /// Theme to use for the [PieMenu].
  final PieTheme theme;

  /// Whether to apply the theme's angleOffset in the paintChildren method.
  /// Set to false when the baseAngle already includes the offset.
  final bool applyAngleOffset;

  @override
  bool shouldRepaint(PieDelegate oldDelegate) {
    return bounceAnimation != oldDelegate.bounceAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final dx = centerOffset.dx - canvasOffset.dx;
    final dy = centerOffset.dy - canvasOffset.dy;
    final count = context.childCount;

    for (var i = 0; i < count; ++i) {
      final size = context.getChildSize(i)!;
      final angleInRadians = applyAngleOffset
          ? radians(baseAngle - theme.angleOffset - angleDiff * (i - 1))
          : radians(baseAngle - angleDiff * (i - 1));

      if (i == 0 && centerOffset == pointerOffset) {
        // Only draw the center pointer for the main menu
        context.paintChild(
          i,
          transform: Matrix4.translationValues(
            dx - size.width / 2,
            dy - size.height / 2,
            0,
          ),
        );
      } else {
        context.paintChild(
          i,
          transform: Matrix4.translationValues(
            dx -
                size.width / 2 +
                radius * cos(angleInRadians) * bounceAnimation.value,
            dy -
                size.height / 2 -
                radius * sin(angleInRadians) * bounceAnimation.value,
            0,
          ),
        );
      }
    }
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tight(
      Size.square(i == 0 && centerOffset == pointerOffset
          ? theme.pointerSize
          : theme.buttonSize),
    );
  }
}
