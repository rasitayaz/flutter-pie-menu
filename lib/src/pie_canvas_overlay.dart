import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_delegate.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Canvas widget that is actually displayed on the screen.
class PieCanvasOverlay extends StatefulWidget {
  const PieCanvasOverlay({
    super.key,
    required this.theme,
    this.onMenuToggle,
    required this.child,
    this.isHighlightedChild = true,
  });

  final PieTheme theme;
  final Function(bool active)? onMenuToggle;
  final Widget child;
  final bool isHighlightedChild;

  @override
  PieCanvasOverlayState createState() => PieCanvasOverlayState();
}

class PieCanvasOverlayState extends State<PieCanvasOverlay> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// * [PieMenu] refers to the menu that is currently displayed on the canvas.

  /// Theme of [PieMenu].
  ///
  /// If [PieMenu] does not have a theme, [PieCanvas] theme is displayed.
  late PieTheme _theme = widget.theme;

  /// Actions of [PieMenu].
  List<PieAction> _actions = [];

  /// Controls [_bounceAnimation].
  late final AnimationController _bounceController = AnimationController(
    duration: widget.theme.pieBounceDuration,
    vsync: this,
  );

  /// Bouncing animation for the [PieButton]s.
  late final Animation _bounceAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _bounceController,
    curve: Curves.elasticOut,
  ));

  /// Whether [_menuChild] is currently pressed.
  bool _pressed = false;

  /// Whether [_menuChild] is pressed again when the menu is active.
  bool _pressedAgain = false;

  /// Whether [PieMenu] is currently active.
  bool menuActive = false;

  /// Whether a [PieMenu] is attached.
  bool _menuAttached = false;

  /// State of [PieMenu].
  PieMenuState? menuState;

  /// Child widget of [PieMenu].
  Widget? _menuChild;

  /// Render box of [_menuChild].
  RenderBox? _menuRenderBox;

  /// Size of [_menuChild].
  Size? get _menuSize => _menuRenderBox?.size;

  /// Offset of [_menuChild].
  Offset get _menuOffset => _menuRenderBox!.localToGlobal(Offset.zero);

  /// Currently pressed pointer offset.
  Offset _pointerOffset = Offset.zero;

  /// Currently hovered [PieButton] index.
  int? _hoveredAction;

  /// Starts when the pointer is down,
  /// is triggered after the delay duration specified in [PieTheme],
  /// and gets cancelled when the pointer is up.
  Timer? _attachTimer;

  /// Starts when the pointer is up,
  /// is triggered after the fade duration specified in [PieTheme],
  /// and gets cancelled when the pointer is down again.
  Timer? _detachTimer;

  /// Tooltip text for the hovered [PieButton].
  String? _tooltip;

  /// Functional callback that is triggered when
  /// the active [PieMenu] is opened and closed.
  Function(bool active)? _onActiveMenuToggle;

  RenderBox? get _renderBox {
    final object = context.findRenderObject();
    return object is RenderBox && object.hasSize ? object : null;
  }

  Offset get _canvasOffset {
    return _renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Size get _canvasSize => _renderBox?.size ?? Size.zero;
  double get _canvasWidth => _canvasSize.width;
  double get _canvasHeight => _canvasSize.height;

  Color get _overlayColor {
    return _theme.overlayColor ?? (_theme.brightness == Brightness.light ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8));
  }

  Color get _pointerColor {
    return _theme.pointerColor ?? (_theme.brightness == Brightness.light ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.5));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Size _metrics = WidgetsBinding.instance.window.physicalSize;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted && menuActive) {
      final previousMetrics = _metrics;
      _metrics = WidgetsBinding.instance.window.physicalSize;
      if (previousMetrics != _metrics) {
        menuActive = false;
        menuState?.setVisibility(true);
        toggleMenu(false);
        _detachMenu();
      }
    }
  }

  TextStyle get _tooltipStyle {
    return _theme.tooltipStyle ??
        TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _theme.brightness == Brightness.light ? Colors.black : Colors.white,
        );
  }

  double get dx => _pointerOffset.dx - _canvasOffset.dx;
  double get dy => _pointerOffset.dy - _canvasOffset.dy;

  double get angleDifference {
    return 7.4 * _theme.buttonSize / sqrt(_theme.distance);
  }

  double get baseAngle {
    final arc = (_actions.length - 1) * angleDifference;
    final dxRatio = dx / _canvasWidth;

    double angleBetween(Offset o1, Offset o2) {
      final slope = (o2.dy - o1.dy) / (o2.dx - o1.dx);
      return degrees(atan(slope));
    }

    final offset = Offset(dx, dy);

    if (dy < _canvasWidth / 2) {
      final origin = Offset(_canvasWidth / 2, _canvasWidth / 2);
      return dx < _canvasWidth / 2 ? arc / 2 - angleBetween(origin, offset) : arc / 2 + 180 - angleBetween(origin, offset);
    } else if (_canvasHeight - dy < _canvasWidth / 2) {
      final origin = Offset(_canvasWidth / 2, _canvasHeight - _canvasWidth / 2);
      return dx < _canvasWidth / 2 ? arc / 2 - angleBetween(origin, offset) : arc / 2 + 180 - angleBetween(origin, offset);
    } else {
      return arc / 2 + 180 * dxRatio;
    }
  }

  double _getActionAngle(int index) {
    return radians(baseAngle - _theme.angleOffset - angleDifference * index);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _pointerDown(event.position),
            onPointerMove: (event) => _pointerMove(event.position),
            onPointerUp: (event) => _pointerUp(event.position),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: menuActive ? const NeverScrollableScrollPhysics() : null,
              ),
              child: IgnorePointer(
                ignoring: menuActive,
                child: widget.child,
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: _theme.fadeDuration,
              opacity: menuActive ? 1 : 0,
              curve: Curves.ease,
              child: Stack(
                children: [
                  /// Pie Menu child below the Overlay
                  if (_menuRenderBox != null && _menuRenderBox!.attached && !widget.isHighlightedChild)
                    Positioned(
                      top: _menuOffset.dy - _canvasOffset.dy,
                      left: _menuOffset.dx - _canvasOffset.dx,
                      child: AnimatedOpacity(
                        opacity: _hoveredAction != null ? 0.5 : 1,
                        duration: _theme.hoverDuration,
                        curve: Curves.ease,
                        child: SizedBox(
                          width: _menuSize!.width,
                          height: _menuSize!.height,
                          child: _menuChild!,
                        ),
                      ),
                    ),

                  /// Overlay
                  Positioned.fill(
                    child: ColoredBox(
                      color: _overlayColor,
                    ),
                  ),

                  /// Pie Menu child on top of the Overlay
                  if (_menuRenderBox != null && _menuRenderBox!.attached && widget.isHighlightedChild)
                    Positioned(
                      top: _menuOffset.dy - _canvasOffset.dy,
                      left: _menuOffset.dx - _canvasOffset.dx,
                      child: AnimatedOpacity(
                        opacity: _hoveredAction != null ? 0.5 : 1,
                        duration: _theme.hoverDuration,
                        curve: Curves.ease,
                        child: SizedBox(
                          width: _menuSize!.width,
                          height: _menuSize!.height,
                          child: _menuChild!,
                        ),
                      ),
                    ),

                  /// Tooltip
                  if (_tooltip != null)
                    Positioned(
                      top: dy < _canvasHeight / 2 ? dy + _theme.distance + _theme.buttonSize : null,
                      bottom: dy >= _canvasHeight / 2 ? _canvasHeight - dy + _theme.distance + _theme.buttonSize : null,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: _theme.tooltipPadding,
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedOpacity(
                                opacity: menuActive && _hoveredAction != null ? 1 : 0,
                                duration: _theme.hoverDuration,
                                curve: Curves.ease,
                                child: Text(
                                  _tooltip!,
                                  textAlign: dx < _canvasWidth / 2 ? TextAlign.right : TextAlign.left,
                                  style: _tooltipStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// Action buttons
                  Flow(
                    delegate: PieDelegate(
                      bounceAnimation: _bounceAnimation,
                      pointerOffset: _pointerOffset,
                      canvasOffset: _canvasOffset,
                      baseAngle: baseAngle,
                      angleDifference: angleDifference,
                      theme: _theme,
                    ),
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _pointerColor,
                            width: 4,
                          ),
                        ),
                      ),
                      for (int i = 0; i < _actions.length; i++)
                        PieButton(
                          action: _actions[i],
                          angle: _getActionAngle(i),
                          menuActive: menuActive,
                          hovered: i == _hoveredAction,
                          theme: _theme,
                          fadeDuration: _theme.fadeDuration,
                          hoverDuration: _theme.hoverDuration,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleMenu(bool active) {
    _onActiveMenuToggle?.call(active);
    widget.onMenuToggle?.call(active);
    if (active) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        /// This rebuild prevents menu child being displayed
        /// in the wrong offset when the scrollable swiped fast.
        setState(() {});
      });
    }
  }

  bool isOutsideOfPointerArea(Offset offset) {
    return (_pointerOffset - offset).distance > _theme.pointerSize / 2;
  }

  void attachMenu({
    required Offset offset,
    required PieMenuState state,
    required Widget child,
    required RenderBox renderBox,
    required List<PieAction> actions,
    required PieTheme? theme,
    required Function(bool menuActive)? onMenuToggle,
  }) {
    _attachTimer?.cancel();
    _detachTimer?.cancel();
    menuState?.setVisibility(true);

    _menuAttached = true;
    _onActiveMenuToggle = onMenuToggle;
    _theme = theme ?? widget.theme;
    _actions = actions;
    menuState = state;
    _menuChild = child;
    _menuRenderBox = renderBox;

    if (!_pressed) {
      _pressed = true;
      _pointerOffset = offset;

      _attachTimer = Timer(_theme.delayDuration, () {
        _detachTimer?.cancel();
        _bounceController.forward(from: 0);
        setState(() {
          menuActive = true;
          _hoveredAction = null;
        });
        toggleMenu(true);

        menuState?.debounce();
        Future.delayed(_theme.fadeDuration, () {
          if (!(_detachTimer?.isActive ?? false)) {
            menuState?.setVisibility(false);
          }
        });
      });
    }
  }

  void _detachMenu({bool afterDelay = true}) {
    _detachTimer = Timer(
      afterDelay ? _theme.fadeDuration : Duration.zero,
      () {
        _attachTimer?.cancel();
        if (_menuAttached) {
          setState(() {
            _pressed = false;
            _pressedAgain = false;
            _tooltip = null;
            _hoveredAction = null;
            menuState = null;
            _menuRenderBox = null;
            _menuChild = null;
            _menuAttached = false;
            menuActive = false;
          });
        }
      },
    );
  }

  void _pointerDown(Offset offset) {
    if (menuActive) {
      _pressedAgain = true;
      _pointerMove(offset);
    }
  }

  void _pointerUp(Offset offset) {
    _attachTimer?.cancel();

    if (menuActive) {
      if (isOutsideOfPointerArea(offset) || _pressedAgain) {
        if (_hoveredAction != null) {
          _actions[_hoveredAction!].onSelect();
        }

        menuState?.setVisibility(true);
        toggleMenu(false);
        setState(() => menuActive = false);

        _detachMenu();
      }
    } else {
      _detachMenu();
    }

    _pressed = false;
    _pressedAgain = false;
  }

  void _pointerMove(Offset offset) {
    if (menuActive) {
      for (int i = 0; i < _actions.length; i++) {
        PieAction action = _actions[i];
        final angle = _getActionAngle(i);
        Offset actionOffset = Offset(
          _pointerOffset.dx + _theme.distance * cos(angle),
          _pointerOffset.dy - _theme.distance * sin(angle),
        );
        if ((actionOffset - offset).distance < _theme.buttonSize / 2 + sqrt(_theme.buttonSize)) {
          if (_hoveredAction != i) {
            setState(() {
              _hoveredAction = i;
              _tooltip = action.tooltip;
            });
          }
          return;
        }
      }
      if (_hoveredAction != null) {
        setState(() => _hoveredAction = null);
      }
    } else if (_pressed && isOutsideOfPointerArea(offset)) {
      _detachMenu(afterDelay: false);
    }
  }
}
