import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/bouncing_widget.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_controller.dart';
import 'package:pie_menu/src/pie_menu_event.dart';
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
    required this.onPressedWithPosition,
    required this.controller,
    required this.child,
  });

  /// Theme to use for this menu, overrides [PieCanvas] theme.
  final PieTheme? theme;

  /// Actions to display as [PieButton]s on the [PieCanvas].
  final List<PieAction> actions;

  /// Widget to be displayed when the menu is hidden.
  final Widget child;

  /// Functional callback triggered when this menu opens or closes.
  final Function(bool menuOpen)? onToggle;

  /// Functional callback triggered on press.
  ///
  /// You can also use [onPressedWithDevice] if you need [PointerDeviceKind].
  /// You can also use [onPressedWithPosition] if you need [Offset].
  final Function()? onPressed;

  /// Functional callback triggered on press.
  /// Provides [PointerDeviceKind] as a parameter.
  ///
  /// Can be useful to distinguish between mouse and touch events.
  final Function(PointerDeviceKind kind)? onPressedWithDevice;

  /// Functional callback triggered on press.
  /// Provides [Offset] as a parameter.
  ///
  /// Can be useful to get the position of the menu.
  final Function(Offset position)? onPressedWithPosition;

  /// Controller for programmatically emitting [PieMenu] events.
  final PieMenuController? controller;

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
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _bounceController,
      curve: _theme.childBounceCurve,
      reverseCurve: _theme.childBounceReverseCurve,
    ),
  );

  /// Offset of the press event.
  var _pressedOffset = Offset.zero;

  // Local offset of the press event.
  var _localPressedOffset = Offset.zero;

  /// Button used for the press event.
  var _pressedButton = 0;

  /// Device kind used for the press event.
  PointerDeviceKind? _pressedDeviceKind;

  /// Whether the menu was open in the previous rebuild.
  var _previouslyOpen = false;

  /// Used to cancel the delayed debounce animation on bounce.
  Timer? _debounceTimer;

  /// Used to measure the time between bounce and debounce.
  final _bounceStopwatch = Stopwatch();

  /// Whether the press was canceled by a pointer move event or menu toggle.
  var _pressCanceled = false;

  /// Used to control the long press recognizer.
  late var _longPressDuration = _theme.longPressDuration;

  /// Used for long press gesture recognition.
  late var _longPressRecognizer = LongPressGestureRecognizer(
    duration: _longPressDuration,
  );

  /// Controls the shared state.
  PieNotifier get _notifier => PieNotifier.of(context);

  /// Current shared state.
  PieState get _state => _notifier.state;

  /// Theme of the current [PieMenu].
  ///
  /// If the [PieMenu] does not have a theme, [PieCanvas] theme is used.
  PieTheme get _theme => widget.theme ?? _notifier.canvas.widget.theme;

  /// Render box of the current widget.
  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_theme.longPressDuration != _longPressDuration) {
      _longPressDuration = _theme.longPressDuration;
      _longPressRecognizer.dispose();
      _longPressRecognizer = LongPressGestureRecognizer(
        duration: _longPressDuration,
      );
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _overlayFadeController.dispose();
    _bounceController.dispose();
    _debounceTimer?.cancel();
    _bounceStopwatch.stop();
    widget.controller?.removeListener(_handleControllerEvent);
    _longPressRecognizer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bounceAnimation = _bounceAnimation;

    if (_state.menuKey == _uniqueKey) {
      if (!_previouslyOpen && _state.menuOpen) {
        _overlayFadeController.forward(from: 0);
        _debounce();
        _pressCanceled = true;
      } else if (_previouslyOpen && !_state.menuOpen) {
        _overlayFadeController.reverse();
      }
    } else {
      if (_overlayFadeController.value != 0) {
        _overlayFadeController.animateTo(0, duration: Duration.zero);
      }
    }

    _previouslyOpen = _state.menuOpen;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (_theme.overlayStyle == PieOverlayStyle.around)
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
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapCancel: _onTapCancel,
              onTapUp: _onTapUp,
              dragStartBehavior: DragStartBehavior.down,
              child: AnimatedOpacity(
                opacity: _theme.overlayStyle == PieOverlayStyle.around &&
                        _state.menuKey == _uniqueKey &&
                        _state.menuOpen &&
                        _state.hoveredAction != null
                    ? _theme.childOpacityOnButtonHover
                    : 1,
                duration: _theme.hoverDuration,
                curve: Curves.ease,
                child: _theme.childBounceEnabled
                    ? BouncingWidget(
                        theme: _theme,
                        animation: bounceAnimation,
                        pressedOffset: _localPressedOffset,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _pointerDown(PointerDownEvent event) {
    if (!mounted) return;

    setState(() {
      _pressedOffset = event.position;
      _localPressedOffset = event.localPosition;
      _pressedButton = event.buttons;
      _pressedDeviceKind = event.kind;
    });

    if (_state.menuOpen) return;

    _pressCanceled = false;

    final isMouseEvent = _pressedDeviceKind == PointerDeviceKind.mouse;
    final leftClicked = isMouseEvent && _pressedButton == kPrimaryMouseButton;
    final rightClicked =
        isMouseEvent && _pressedButton == kSecondaryMouseButton;

    if (isMouseEvent && !leftClicked && !rightClicked) return;

    if (rightClicked && !_theme.rightClickShowsMenu) return;

    if (_theme.longPressDuration < Duration(milliseconds: 100) ||
        rightClicked) {
      _bounce();
    }

    if (leftClicked && !_theme.leftClickShowsMenu) return;

    if (rightClicked && _theme.rightClickShowsMenu) {
      _attachMenu(rightClicked: true, offset: _pressedOffset);
    }

    if (!rightClicked && _theme.longPressShowsMenu) {
      _longPressRecognizer
        ..onLongPress = () {
          _attachMenu(offset: _pressedOffset);
        }
        ..addPointer(event);
    }
  }

  void _onTapDown(TapDownDetails details) {
    _bounce();
  }

  void _pointerMove(PointerMoveEvent event) {
    if (!mounted || _state.menuOpen) return;

    if ((_pressedOffset - event.position).distance > 8) {
      _pressCanceled = true;
      _debounce();
    }
  }

  void _onTapCancel() {
    _debounce();
  }

  void _onTapUp(TapUpDetails details) {
    if (!mounted) return;

    _debounce();

    if (_pressCanceled || _state.menuOpen) return;

    final deviceKind = _pressedDeviceKind;

    final isMouseEvent = deviceKind == PointerDeviceKind.mouse;
    final leftClicked = isMouseEvent && _pressedButton == kPrimaryMouseButton;
    final rightClicked =
        isMouseEvent && _pressedButton == kSecondaryMouseButton;

    if (!rightClicked) {
      widget.onPressed?.call();
      if (deviceKind != null) {
        widget.onPressedWithDevice?.call(deviceKind);
      }
    }

    if (!_theme.regularPressShowsMenu) return;
    if (leftClicked && !_theme.leftClickShowsMenu) return;
    if (rightClicked && !_theme.rightClickShowsMenu) return;

    _attachMenu(offset: _pressedOffset);
  }

  void _bounce() {
    if (!mounted || !_theme.childBounceEnabled || _bounceStopwatch.isRunning) {
      return;
    }

    _debounceTimer?.cancel();
    _bounceStopwatch.reset();
    _bounceStopwatch.start();

    _bounceController.forward();
  }

  void _debounce() {
    if (!mounted || !_theme.childBounceEnabled || !_bounceStopwatch.isRunning) {
      return;
    }

    _bounceStopwatch.stop();

    final minDelayMS = 100;

    final debounceDelay = _bounceStopwatch.elapsedMilliseconds > minDelayMS
        ? Duration.zero
        : Duration(milliseconds: minDelayMS);

    _debounceTimer = Timer(debounceDelay, () {
      _bounceController.reverse();
    });
  }

  void _attachMenu({
    bool rightClicked = false,
    Offset? offset,
    Alignment? menuAlignment,
    Offset? menuDisplacement,
  }) {
    assert(
      offset != null || menuAlignment != null,
      'Offset or alignment must be provided.',
    );

    widget.onPressedWithPosition?.call(_pressedOffset);

    _notifier.canvas.attachMenu(
      rightClicked: rightClicked,
      offset: offset,
      renderBox: _renderBox!,
      child: widget.child,
      bounceAnimation: _bounceAnimation,
      menuKey: _uniqueKey,
      actions: widget.actions,
      theme: _theme,
      onMenuToggle: widget.onToggle,
      menuAlignment: menuAlignment,
      menuDisplacement: menuDisplacement,
    );
  }

  void _handleControllerEvent() {
    final controller = widget.controller;
    if (controller == null) return;
    final event = controller.value;

    if (event is PieMenuOpenEvent) {
      _onOpenMenu(event);
    } else if (event is PieMenuCloseEvent) {
      _onCloseMenu(event);
    } else if (event is PieMenuToggleEvent) {
      _onToggleMenu(event);
    }
  }

  void _onOpenMenu(PieMenuOpenEvent event) {
    _attachMenu(
      menuAlignment: event.menuAlignment,
      menuDisplacement: event.menuDisplacement,
    );
  }

  void _onCloseMenu(PieMenuCloseEvent event) {
    _notifier.canvas.closeMenu(_uniqueKey);
  }

  void _onToggleMenu(PieMenuToggleEvent event) {
    if (_state.menuKey == _uniqueKey) {
      _notifier.canvas.closeMenu(_uniqueKey);
    } else {
      _attachMenu(
        menuAlignment: event.menuAlignment,
        menuDisplacement: event.menuDisplacement,
      );
    }
  }
}
