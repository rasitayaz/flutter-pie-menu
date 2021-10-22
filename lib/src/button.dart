import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/action.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/menu.dart';
import 'package:pie_menu/src/theme.dart';

/// Displays [PieAction]s of the [PieMenu] on the [PieCanvas].
class PieButton extends StatefulWidget {
  /// Creates a [PieButton] that is specialized for a [PieAction].
  const PieButton({
    Key? key,
    required this.action,
    required this.menuOpen,
    required this.hovered,
    required this.theme,
    required this.fadeDuration,
    required this.hoverDuration,
  }) : super(key: key);

  /// Action to display.
  final PieAction action;

  /// Whether the [PieMenu] this [PieButton] belongs to is open.
  final bool menuOpen;

  /// Whether this [PieButton] is currently hovered.
  final bool hovered;

  /// Behavioral and visual structure of this button.
  final PieTheme theme;

  /// Duration of the [PieMenu] fade animation.
  final Duration fadeDuration;

  /// Duration of the [PieButton] hover animation.
  final Duration hoverDuration;

  @override
  _PieButtonState createState() => _PieButtonState();
}

class _PieButtonState extends State<PieButton>
    with SingleTickerProviderStateMixin {
  /// Controls [animation].
  late AnimationController controller;

  /// Fade animation for the [PieButton]s.
  late Animation animation;

  /// Wether the [PieButton] is visible.
  bool visible = false;

  PieButtonTheme get buttonTheme {
    return widget.action.buttonTheme ?? widget.theme.buttonTheme;
  }

  PieButtonTheme get hoveredButtonTheme {
    return widget.action.hoveredButtonTheme ?? widget.theme.hoveredButtonTheme;
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    )..addListener(() => setState(() {}));

    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.ease));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.menuOpen) {
      visible = false;
    } else if (widget.menuOpen && !visible) {
      visible = true;
      controller.forward(from: 0);
    }

    return OverflowBox(
      maxHeight: widget.theme.buttonSize * 2,
      maxWidth: widget.theme.buttonSize * 2,
      child: AnimatedScale(
        scale: widget.hovered ? 1.2 : 1,
        duration: widget.hoverDuration,
        curve: Curves.ease,
        child: Transform.scale(
          scale: animation.value,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.hoverDuration,
                curve: Curves.ease,
                top: widget.hovered
                    ? widget.theme.buttonSize / 2 -
                        sin(widget.action.angle) *
                            widget.theme.hoverDisplacement
                    : widget.theme.buttonSize / 2,
                right: widget.hovered
                    ? widget.theme.buttonSize / 2 -
                        cos(widget.action.angle) *
                            widget.theme.hoverDisplacement
                    : widget.theme.buttonSize / 2,
                child: Container(
                  height: widget.theme.buttonSize,
                  width: widget.theme.buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.hovered
                        ? hoveredButtonTheme.backgroundColor
                        : buttonTheme.backgroundColor,
                  ),
                  child: Center(
                    child: Padding(
                      padding: widget.action.padding,
                      child: (widget.hovered
                              ? (widget.action.customHoveredWidget ??
                                  widget.action.customWidget)
                              : widget.action.customWidget) ??
                          Icon(
                            widget.action.iconData,
                            size: widget.action.iconSize,
                            color: widget.hovered
                                ? hoveredButtonTheme.iconColor
                                : buttonTheme.iconColor,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
