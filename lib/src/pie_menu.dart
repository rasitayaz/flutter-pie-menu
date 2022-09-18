import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_canvas_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Widget that displays [PieAction]s as circular buttons for its child.
class PieMenu extends StatefulWidget {
  const PieMenu({
    super.key,
    this.theme,
    this.actions = const [],
    this.onToggle,
    this.onTap,
    required this.child,
  });

  /// Theme to use for this menu, overrides [PieCanvas] theme.
  final PieTheme? theme;

  /// Actions to display as [PieButton]s on the [PieCanvas].
  final List<PieAction> actions;

  /// Widget to be displayed when the menu is hidden.
  final Widget child;

  /// Functional callback that is triggered when
  /// this [PieMenu] is opened and closed.
  final Function(bool active)? onToggle;

  final VoidCallback? onTap;

  @override
  State<PieMenu> createState() => PieMenuState();
}

class PieMenuState extends State<PieMenu> with SingleTickerProviderStateMixin {
  bool _childVisible = true;

  Offset _offset = Offset.zero;

  bool _bouncing = false;
  final _bounceStopwatch = Stopwatch();

  PieCanvasProvider get _canvasProvider => PieCanvasProvider.of(context);

  PieTheme get _theme => widget.theme ?? _canvasProvider.theme;

  PieCanvasOverlayState get _canvas => _canvasProvider.canvasKey.currentState!;

  /// Controls [_menuBounceAnimation].
  late final AnimationController _menuBounceController = AnimationController(
    duration: _theme.menuBounceDuration,
    vsync: this,
  );

  /// Bouncing animation for [PieMenu].
  late final Animation<double> _menuBounceAnimation = Tween(
    begin: 1.0,
    end: _theme.menuBounceDepth,
  ).animate(CurvedAnimation(
    parent: _menuBounceController,
    curve: _theme.menuBounceCurve,
    reverseCurve: _theme.menuBounceReverseCurve,
  ));

  Widget get _bouncingChild {
    return ScaleTransition(
      scale: _menuBounceAnimation,
      child: widget.child,
    );
  }

  void setVisibility(bool visible) {
    if (visible != _childVisible) {
      setState(() => _childVisible = visible);
    }
  }

  void debounce() async {
    if (!mounted || !_theme.bouncingMenu) return;

    if (_bouncing) {
      _bouncing = false;

      if (_bounceStopwatch.elapsed > _theme.menuBounceDuration) {
        _menuBounceController.reverse();
      } else {
        Future.delayed(
          _theme.menuBounceDuration - _bounceStopwatch.elapsed,
          () {
            if (mounted) {
              _menuBounceController.reverse();
            }
          },
        );
      }

      _bounceStopwatch.stop();
      _bounceStopwatch.reset();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _menuBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _offset = event.position;

        if (!_canvas.menuActive) {
          if (_theme.delayDuration == Duration.zero) {
            widget.onTap?.call();
          }

          if (_theme.bouncingMenu) {
            _menuBounceController.forward();
            _bouncing = true;
            _bounceStopwatch.start();
          }

          _canvas.attachMenu(
            offset: _offset,
            state: this,
            child: _bouncingChild,
            renderBox: context.findRenderObject() as RenderBox,
            actions: widget.actions,
            theme: widget.theme,
            onMenuToggle: widget.onToggle,
          );
        }
      },
      onPointerMove: (event) {
        if ((event.position - _offset).distance > _theme.pointerSize / 2) {
          debounce();
        }
      },
      onPointerUp: (event) {
        if (!_canvas.menuActive && _offset == event.position) {
          widget.onTap?.call();
        }
        debounce();
      },
      child: Opacity(
        opacity: _childVisible ? 1 : 0,
        child: _bouncingChild,
      ),
    );
  }
}
