import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
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
    this.onPressed,
    this.onPressedWithDevice,
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

  /// Functional callback that is triggered on press.
  ///
  /// You can also use [onPressedWithDevice] if you need [PointerDeviceKind].
  final Function()? onPressed;

  /// Functional callback with [PointerDeviceKind] details
  /// that is triggered on press.
  final Function(PointerDeviceKind kind)? onPressedWithDevice;

  @override
  State<PieMenu> createState() => PieMenuState();
}

class PieMenuState extends State<PieMenu> with SingleTickerProviderStateMixin {
  var _childVisible = true;

  var _pressedOffset = Offset.zero;
  var _pressedButton = 0;

  var _bouncing = false;
  final _bounceStopwatch = Stopwatch();

  PieCanvasProvider get _canvasProvider => PieCanvasProvider.of(context);

  PieTheme get _theme => widget.theme ?? _canvasProvider.theme;

  PieCanvasOverlayState get _canvas => _canvasProvider.canvasKey.currentState!;

  Size? _size;

  Duration get _bounceDuration => _theme.childBounceDuration;

  /// Controls [_bounceAnimation].
  late final AnimationController _bounceController = AnimationController(
    duration: _bounceDuration,
    vsync: this,
  );

  Animation<double> _getAnimation(double depth) {
    return Tween(
      begin: 1.0,
      end: depth,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: _theme.childBounceCurve,
      reverseCurve: _theme.childBounceReverseCurve,
    ));
  }

  /// Bouncing animation for [PieMenu].
  late Animation<double> _bounceAnimation = _getAnimation(1);

  Widget get _bouncingChild {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: widget.child,
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void setVisibility(bool visible) {
    if (visible != _childVisible) {
      setState(() => _childVisible = visible);
    }
  }

  void debounce() {
    if (!mounted || !_theme.childBounce) return;

    if (_bouncing) {
      _bouncing = false;

      if (_bounceStopwatch.elapsed > _bounceDuration || !_canvas.menuActive) {
        _bounceController.reverse();
      } else {
        Future.delayed(_bounceDuration - _bounceStopwatch.elapsed, () {
          if (mounted) {
            _bounceController.reverse();
          }
        });
      }

      _bounceStopwatch.stop();
      _bounceStopwatch.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        final size = context.size;

        if (_size != size && size != null && !size.isEmpty) {
          _size = context.size;

          final effectiveSize = max(size.width, size.height);
          final depth = max(
            (effectiveSize - _theme.childBounceDistance) / effectiveSize,
            0.0,
          );

          setState(() => _bounceAnimation = _getAnimation(depth));
        }
      }
    });

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _pressedOffset = event.position;
          _pressedButton = event.buttons;

          if (_canvas.menuActive) return;

          final isMouseEvent = event.kind == PointerDeviceKind.mouse;
          final leftClicked =
              isMouseEvent && _pressedButton == kPrimaryMouseButton;
          final rightClicked =
              isMouseEvent && _pressedButton == kSecondaryMouseButton;

          if (isMouseEvent && !leftClicked && !rightClicked) return;

          if (rightClicked && !_theme.rightClickShowsMenu) return;

          if (leftClicked &&
              !_theme.leftClickShowsMenu &&
              widget.onPressed == null &&
              widget.onPressedWithDevice == null) {
            return;
          }

          if (_theme.childBounce) {
            _bouncing = true;
            _bounceStopwatch.start();
            _bounceController.forward();
          }

          if (leftClicked && !_theme.leftClickShowsMenu) return;

          _canvas.attachMenu(
            rightClicked: rightClicked,
            offset: _pressedOffset,
            state: this,
            child: _bouncingChild,
            renderBox: context.findRenderObject() as RenderBox,
            actions: widget.actions,
            theme: widget.theme,
            onMenuToggle: widget.onToggle,
          );
        },
        onPointerMove: (event) {
          if ((event.position - _pressedOffset).distance >
              _theme.pointerSize / 2) {
            debounce();
          }
        },
        onPointerUp: (event) {
          debounce();

          if ((_pressedOffset - event.position).distance > 8) return;
          if (_canvas.menuActive && _theme.delayDuration != Duration.zero) {
            return;
          }
          if (event.kind == PointerDeviceKind.mouse &&
              _pressedButton != kPrimaryMouseButton) {
            return;
          }

          widget.onPressed?.call();
          widget.onPressedWithDevice?.call(event.kind);
        },
        child: Opacity(
          opacity: _childVisible ? 1 : 0,
          child: _bouncingChild,
        ),
      ),
    );
  }
}
