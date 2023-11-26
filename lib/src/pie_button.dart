import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';

/// Displays [PieAction]s of the [PieMenu] on the [PieCanvas].
class PieButton extends StatefulWidget {
  /// Creates a [PieButton] that is specialized for a [PieAction].
  const PieButton({
    super.key,
    required this.action,
    required this.hovered,
    required this.angle,
  });

  /// Action to display.
  final PieAction action;

  /// Whether this [PieButton] is currently hovered.
  final bool hovered;

  /// Display angle of [PieButton] in radians.
  final double angle;

  @override
  State<PieButton> createState() => _PieButtonState();
}

class _PieButtonState extends State<PieButton>
    with SingleTickerProviderStateMixin {
  /// Controls [_scaleAnimation].
  late final _scaleController = AnimationController(
    duration: Duration(
      milliseconds: _theme.bounceDuration.inMilliseconds ~/ 2,
    ),
    vsync: this,
  );

  /// Fade animation for the [PieButton]s.
  late final _scaleAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _scaleController,
      curve: Curves.ease,
    ),
  );

  PieAction get _action => widget.action;

  PieButtonTheme get _buttonTheme {
    return _action.buttonTheme ?? _theme.buttonTheme;
  }

  PieButtonTheme get _buttonThemeHovered {
    return _action.buttonThemeHovered ?? _theme.buttonThemeHovered;
  }

  PieState get _state => PieNotifier.of(context).state;

  PieTheme get _theme => _state.theme;

  var _previouslyActive = false;

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_previouslyActive && _state.active) {
      _scaleController.forward(from: 0);
    }

    _previouslyActive = _state.active;

    return OverflowBox(
      maxHeight: _theme.buttonSize * 2,
      maxWidth: _theme.buttonSize * 2,
      child: AnimatedScale(
        scale: widget.hovered ? 1.2 : 1,
        duration: _theme.hoverDuration,
        curve: Curves.ease,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: _theme.hoverDuration,
                curve: Curves.ease,
                top: widget.hovered
                    ? _theme.buttonSize / 2 -
                        sin(widget.angle) * _theme.hoverDisplacement
                    : _theme.buttonSize / 2,
                right: widget.hovered
                    ? _theme.buttonSize / 2 -
                        cos(widget.angle) * _theme.hoverDisplacement
                    : _theme.buttonSize / 2,
                child: Container(
                  height: _theme.buttonSize,
                  width: _theme.buttonSize,
                  decoration: (widget.hovered
                          ? _buttonThemeHovered.decoration
                          : _buttonTheme.decoration) ??
                      BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.hovered
                            ? _buttonThemeHovered.backgroundColor
                            : _buttonTheme.backgroundColor,
                      ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: widget.hovered
                            ? _buttonThemeHovered.iconColor
                            : _buttonTheme.iconColor,
                        size: _theme.iconSize,
                      ),
                      child: _action.builder?.call(widget.hovered) ??
                          _action.child!,
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
