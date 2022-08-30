import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

/// Customized [FlowDelegate] to size and position children efficiently.
class PieDelegate extends FlowDelegate {
  PieDelegate({
    required this.bounceAnimation,
    required this.pointerOffset,
    required this.canvasOffset,
    required this.baseAngle,
    required this.angleDifference,
    required this.theme,
  }) : super(repaint: bounceAnimation);

  /// Bouncing animation for the [PieButton]s.
  final Animation bounceAnimation;

  /// Offset of the widget displayed in the center of the [PieMenu].
  final Offset pointerOffset;

  /// Offset of the [PieCanvas].
  final Offset canvasOffset;

  /// Angle of the first [PieButton] in degrees.
  final double baseAngle;

  /// Angle difference between the [PieButton]s in degrees.
  final double angleDifference;

  /// Theme to use for the [PieMenu].
  final PieTheme theme;

  @override
  bool shouldRepaint(PieDelegate oldDelegate) {
    return bounceAnimation != oldDelegate.bounceAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dx = pointerOffset.dx - canvasOffset.dx;
    double dy = pointerOffset.dy - canvasOffset.dy;
    int count = context.childCount;

    for (int i = 0; i < count; ++i) {
      Size size = context.getChildSize(i)!;
      double angle = baseAngle - angleDifference * (i - 1);
      if (i == 0) {
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
                theme.distance * cos(radians(angle)) * bounceAnimation.value,
            dy -
                size.height / 2 -
                theme.distance * sin(radians(angle)) * bounceAnimation.value,
            0,
          ),
        );
      }
    }
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    Size size = i == 0
        ? Size(theme.pointerSize, theme.pointerSize)
        : Size(theme.buttonSize, theme.buttonSize);
    return BoxConstraints.tight(size);
  }
}
