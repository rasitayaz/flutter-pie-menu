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
    required this.pieMenuOpenAnimation,
    required this.pointerOffset,
    required this.canvasOffset,
    required this.baseAngle,
    required this.angleDiff,
    required this.theme,
  }) : super(repaint: pieMenuOpenAnimation);

  /// Bouncing animation for the buttons.
  final Animation<double> pieMenuOpenAnimation;

  /// Offset of the widget displayed in the center of the [PieMenu].
  final Offset pointerOffset;

  /// Offset of the [PieCanvas].
  final Offset canvasOffset;

  /// Angle of the first [PieButton] in degrees.
  final double baseAngle;

  /// Angle difference between the [PieButton]s in degrees.
  final double angleDiff;

  /// Theme to use for the [PieMenu].
  final PieTheme theme;

  @override
  bool shouldRepaint(PieDelegate oldDelegate) {
    return pieMenuOpenAnimation != oldDelegate.pieMenuOpenAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final dx = pointerOffset.dx - canvasOffset.dx;
    final dy = pointerOffset.dy - canvasOffset.dy;
    final count = context.childCount;

    for (var i = 0; i < count; ++i) {
      final size = context.getChildSize(i)!;
      final angleInRadians = radians(baseAngle - theme.angleOffset - angleDiff * (i - 1));
      if (theme.animationTheme.pieMenuOpenBuilder != null) {
        context.paintChild(
          i,
          transform: theme.animationTheme.pieMenuOpenBuilder!(
            i,
            Offset(dx, dy),
            size,
            angleInRadians,
            pieMenuOpenAnimation,
          ),
        );
      } else {
        final nthMultiplier = i == 0 ? 0 : 1;
        context.paintChild(
          i,
          transform: Matrix4.translationValues(
            (dx - size.width / 2) + (nthMultiplier * theme.radius * cos(angleInRadians) * pieMenuOpenAnimation.value),
            (dy - size.height / 2) - (nthMultiplier * theme.radius * sin(angleInRadians) * pieMenuOpenAnimation.value),
            0,
          ),
        );
      }
    }
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tight(
      Size.square(i == 0 ? theme.pointerSize : theme.buttonSize),
    );
  }
}
