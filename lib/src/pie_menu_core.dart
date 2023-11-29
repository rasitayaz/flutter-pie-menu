import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Controls functionality and appearance of [PieMenu].
class PieMenuCore extends StatefulWidget {
  const PieMenuCore({
    super.key,
    required this.theme,
    required this.actions,
    required this.onToggle,
    required this.onPressed,
    required this.onPressedWithDevice,
    required this.child,
  });

  /// Theme to use for this menu, overrides [PieCanvas] theme.
  final PieTheme? theme;

  /// Actions to display as [PieButton]s on the [PieCanvas].
  final List<PieAction> actions;

  /// Widget to be displayed when the menu is hidden.
  final Widget child;

  /// Functional callback triggered when
  /// this [PieMenu] becomes active or inactive.
  final Function(bool active)? onToggle;

  /// Functional callback triggered on press.
  ///
  /// You can also use [onPressedWithDevice] if you need [PointerDeviceKind].
  final Function()? onPressed;

  /// Functional callback triggered on press.
  /// Provides [PointerDeviceKind] as a parameter.
  ///
  /// Can be useful to distinguish between mouse and touch events.
  final Function(PointerDeviceKind kind)? onPressedWithDevice;

  @override
  State<PieMenuCore> createState() => _PieMenuCoreState();
}

class _PieMenuCoreState extends State<PieMenuCore>
    with TickerProviderStateMixin {
  /// Unique key for this menu. Used to control animations.
  final _uniqueKey = UniqueKey();

  /// Controls [_overlayFadeAnimation].
  late final _overlayFadeController = AnimationController(
    duration: _theme.fadeDuration,
    vsync: this,
  );

  /// Fade animation for the menu overlay.
  late final _overlayFadeAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _overlayFadeController,
      curve: Curves.ease,
    ),
  );

  /// Controls [_bounceAnimation].
  late final _bounceController = AnimationController(
    duration: _theme.childBounceDuration,
    vsync: this,
  );

  /// Bounce animation for the child widget.
  late final _bounceAnimation = Tween(
    begin: 1.0,
    end: _theme.childBounceFactor,
  ).animate(
    CurvedAnimation(
      parent: _bounceController,
      curve: _theme.childBounceCurve,
      reverseCurve: _theme.childBounceReverseCurve,
    ),
  );

  /// Offset of the press event.
  var _pressedOffset = Offset.zero;

  /// Button used for the press event.
  var _pressedButton = 0;

  /// Whether the menu was active in the previous rebuild.
  var _previouslyActive = false;

  /// Used to cancel the delayed debounce animation on bounce.
  Timer? _debounceTimer;

  /// Used to measure the time between bounce and debounce.
  final _bounceStopwatch = Stopwatch();

  /// Controls the shared state.
  PieNotifier get _notifier => PieNotifier.of(context);

  /// Current shared state.
  PieState get _state => _notifier.state;

  /// Theme of the current [PieMenu].
  ///
  /// If the [PieMenu] does not have a theme, [PieCanvas] theme is used.
  PieTheme get _theme => widget.theme ?? _notifier.canvasTheme;

  @override
  void dispose() {
    _overlayFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state.menuKey == _uniqueKey) {
      if (!_previouslyActive && _state.active) {
        _overlayFadeController.forward(from: 0);
        _debounce();
      } else if (_previouslyActive && !_state.active) {
        _overlayFadeController.reverse();
      }
    } else {
      if (_overlayFadeController.value != 0) {
        _overlayFadeController.animateTo(0, duration: Duration.zero);
      }
    }

    _previouslyActive = _state.active;

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _overlayFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _overlayFadeAnimation.value,
                child: child,
              );
            },
            child: ColoredBox(color: _theme.effectiveOverlayColor),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerDown: _pointerDown,
            onPointerMove: _pointerMove,
            onPointerUp: _pointerUp,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }

  void _pointerDown(PointerDownEvent event) async {
    _pressedOffset = event.position;
    _pressedButton = event.buttons;

    if (_state.active) return;

    _bounce();

    final isMouseEvent = event.kind == PointerDeviceKind.mouse;
    final leftClicked = isMouseEvent && _pressedButton == kPrimaryMouseButton;
    final rightClicked =
        isMouseEvent && _pressedButton == kSecondaryMouseButton;

    if (isMouseEvent && !leftClicked && !rightClicked) return;

    if (rightClicked && !_theme.rightClickShowsMenu) return;

    if (leftClicked && !_theme.leftClickShowsMenu) return;

    _notifier.canvas.attachMenu(
      rightClicked: rightClicked,
      offset: _pressedOffset,
      renderBox: context.findRenderObject() as RenderBox,
      menuKey: _uniqueKey,
      actions: widget.actions,
      theme: _theme,
      onMenuToggle: widget.onToggle,
    );

    final recognizer = LongPressGestureRecognizer(
      duration: _theme.delayDuration,
    );
    recognizer.onLongPressUp = () {};
    recognizer.addPointer(event);
  }

  void _pointerMove(PointerMoveEvent event) {
    if (_state.active) return;

    if ((_pressedOffset - event.position).distance > 8) {
      _debounce();
    }
  }

  void _pointerUp(PointerUpEvent event) {
    _debounce();

    if ((_pressedOffset - event.position).distance > 8) {
      return;
    }

    if (_state.active && _theme.delayDuration != Duration.zero) {
      return;
    }

    if (event.kind == PointerDeviceKind.mouse &&
        _pressedButton != kPrimaryMouseButton) {
      return;
    }

    widget.onPressed?.call();
    widget.onPressedWithDevice?.call(event.kind);
  }

  void _bounce() {
    if (!_theme.childBounceEnabled) return;

    _bounceController.forward();

    _debounceTimer?.cancel();
    _bounceStopwatch.reset();
    _bounceStopwatch.start();
  }

  void _debounce() {
    if (!_theme.childBounceEnabled || !_bounceStopwatch.isRunning) return;

    _bounceStopwatch.stop();

    final debounceDelay = _bounceStopwatch.elapsedMilliseconds > 100
        ? Duration.zero
        : const Duration(milliseconds: 100);

    _debounceTimer = Timer(debounceDelay, () {
      if (mounted) _bounceController.reverse();
    });
  }
}
