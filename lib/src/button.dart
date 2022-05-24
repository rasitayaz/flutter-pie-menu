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
    super.key,
    required this.action,
    required this.menuOpen,
    required this.hovered,
    required this.theme,
    required this.fadeDuration,
    required this.hoverDuration,
  });

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
  State<PieButton> createState() => _PieButtonState();
}

class _PieButtonState extends State<PieButton>
    with SingleTickerProviderStateMixin {
  /// Controls [animation].
  late AnimationController controller;

  /// Fade animation for the [PieButton]s.
  late Animation animation;

  /// Wether the [PieButton] is visible.
  bool visible = false;

  PieAction get action => widget.action;
  PieTheme get theme => widget.theme;

  PieButtonTheme get buttonTheme {
    return action.buttonTheme ?? theme.buttonTheme;
  }

  PieButtonTheme get buttonThemeHovered {
    return action.buttonThemeHovered ?? theme.buttonThemeHovered;
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
      maxHeight: theme.buttonSize * 2,
      maxWidth: theme.buttonSize * 2,
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
                    ? theme.buttonSize / 2 -
                        sin(action.angle) * theme.hoverDisplacement
                    : theme.buttonSize / 2,
                right: widget.hovered
                    ? theme.buttonSize / 2 -
                        cos(action.angle) * theme.hoverDisplacement
                    : theme.buttonSize / 2,
                child: Container(
                  height: theme.buttonSize,
                  width: theme.buttonSize,
                  decoration: (widget.hovered
                          ? buttonThemeHovered.decoration
                          : buttonTheme.decoration) ??
                      BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.hovered
                            ? buttonThemeHovered.backgroundColor
                            : buttonTheme.backgroundColor,
                      ),
                  child: Center(
                    child: Padding(
                      padding: action.padding,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(
                            color: widget.hovered
                                ? buttonThemeHovered.iconColor
                                : buttonTheme.iconColor,
                            size: theme.iconSize,
                          ),
                        ),
                        child: widget.hovered
                            ? (action.childHovered ?? action.child)
                            : action.child,
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
