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
  });

  final PieTheme theme;
  final Function(bool menuVisible)? onMenuToggle;
  final Widget child;

  @override
  PieCanvasOverlayState createState() => PieCanvasOverlayState();
}

class PieCanvasOverlayState extends State<PieCanvasOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// * [PieMenu] refers to the menu that is currently displayed on the canvas.

  /// Theme of the [PieMenu].
  ///
  /// If [PieMenu] does not have a theme, [PieCanvas] theme is displayed.
  late PieTheme _theme = widget.theme;

  /// Actions of the [PieMenu].
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

  /// Whether the [_menuChild] is currently pressed.
  bool _pressed = false;

  /// Whether the [_menuChild] is pressed when the menu is visible.
  bool _pressedAgain = false;

  /// Whether the [PieMenu] is currently visible.
  bool menuVisible = false;

  /// Whether a [PieMenu] is pressed.
  bool _menuAttached = false;

  /// State of the current [PieMenu].
  PieMenuState? menuState;

  /// Child widget of the [PieMenu].
  Widget? _menuChild;

  /// Render box of the [_menuChild].
  RenderBox? _menuRenderBox;

  /// Size of the [_menuChild].
  Size? get _menuSize => _menuRenderBox?.size;

  /// Offset of the [_menuChild].
  Offset get _menuOffset => _menuRenderBox!.localToGlobal(Offset.zero);

  /// Currently pressed pointer offset.
  Offset _pointerOffset = Offset.zero;

  /// Currently hovered [PieButton] index.
  int _hoveredAction = -1;

  /// Starts when the pointer is down,
  /// is triggered after the delay duration specified in [PieTheme],
  /// and gets cancelled when the pointer is up.
  Timer? _pointerDownTimer;

  /// Starts when the pointer is up,
  /// is triggered after the fade duration specified in [PieTheme],
  /// and gets cancelled when the pointer is down again.
  Timer? _pointerUpTimer;

  /// Tooltip text for the hovered [PieButton].
  String? _tooltip;

  /// Functional callback that is triggered when
  /// the active [PieMenu] is opened and closed.
  Function(bool menuVisible)? _onActiveMenuToggle;

  RenderBox? get _renderBox {
    final renderObject = context.findRenderObject();
    return renderObject is RenderBox ? renderObject : null;
  }

  Offset get _canvasOffset {
    return _renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Size get _canvasSize {
    return _renderBox?.size ?? Size.zero;
  }

  Color get _overlayColor {
    return _theme.overlayColor ??
        (_theme.brightness == Brightness.light
            ? Colors.white.withOpacity(0.8)
            : Colors.black.withOpacity(0.8));
  }

  Color get _pointerColor {
    return _theme.pointerColor ??
        (_theme.brightness == Brightness.light
            ? Colors.black.withOpacity(0.35)
            : Colors.white.withOpacity(0.5));
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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted && menuVisible) {
      menuState?.setVisibility(true);
      toggleMenu(false);
      _detachMenu();
    }
  }

  TextStyle get _tooltipStyle {
    return _theme.tooltipStyle ??
        TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _theme.brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        );
  }

  @override
  Widget build(BuildContext context) {
    double dx = _pointerOffset.dx - _canvasOffset.dx;
    double dy = _pointerOffset.dy - _canvasOffset.dy;
    double angleDifference = 7.4 * _theme.buttonSize / sqrt(_theme.distance);
    double arc = (_actions.length - 1) * angleDifference;
    double dxRatio = dx / _canvasSize.width;
    double baseAngle = dy >
            _theme.distance +
                _theme.buttonSize +
                MediaQuery.of(context).padding.top
        ? (arc / 2) + 180 * dxRatio
        : (arc / 2) - 180 * dxRatio;

    for (int i = 0; i < _actions.length; i++) {
      _actions[i].angle = radians(baseAngle - angleDifference * i);
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _pointerDown(event.position),
            onPointerMove: (event) => _pointerMove(event.position),
            onPointerUp: (event) => _pointerUp(event.position),
            child: widget.child,
          ),
          IgnorePointer(
            child: Stack(
              children: [
                /// Overlay
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: _theme.fadeDuration,
                    opacity: menuVisible ? 1 : 0,
                    curve: Curves.ease,
                    child: ColoredBox(
                      color: _overlayColor,
                    ),
                  ),
                ),

                /// Pie Menu child
                if (_menuRenderBox != null && _menuRenderBox!.attached)
                  Positioned(
                    top: _menuOffset.dy - _canvasOffset.dy,
                    left: _menuOffset.dx - _canvasOffset.dx,
                    child: AnimatedOpacity(
                      opacity: _hoveredAction >= 0 ? 0.5 : 1,
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
                    top: dy < _canvasSize.height / 2
                        ? dy + _theme.distance + _theme.buttonSize
                        : null,
                    bottom: dy >= _canvasSize.height / 2
                        ? _canvasSize.height -
                            dy +
                            _theme.distance +
                            _theme.buttonSize
                        : null,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: _theme.tooltipPadding,
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedOpacity(
                              opacity:
                                  menuVisible && _hoveredAction >= 0 ? 1 : 0,
                              duration: _theme.hoverDuration,
                              curve: Curves.ease,
                              child: Text(
                                _tooltip!,
                                textAlign: dx < _canvasSize.width / 2
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: _tooltipStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// Action buttons
                AnimatedOpacity(
                  duration: _theme.fadeDuration,
                  opacity: menuVisible ? 1 : 0,
                  curve: Curves.ease,
                  child: Flow(
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
                          menuOpen: menuVisible,
                          hovered: i == _hoveredAction,
                          theme: _theme,
                          fadeDuration: _theme.fadeDuration,
                          hoverDuration: _theme.hoverDuration,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void toggleMenu(bool menuVisible) {
    _onActiveMenuToggle?.call(menuVisible);
    widget.onMenuToggle?.call(menuVisible);
    if (menuVisible) {
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
    required PieMenuState state,
    required Widget child,
    required RenderBox renderBox,
    required List<PieAction> actions,
    required PieTheme? theme,
    required Function(bool menuVisible)? onMenuToggle,
  }) {
    if (menuVisible) {
      _pressedAgain = true;
    } else if (!_pressed) {
      _pointerDownTimer?.cancel();
      _pointerUpTimer?.cancel();
      menuState?.setVisibility(true);

      _menuAttached = true;
      _onActiveMenuToggle = onMenuToggle;
      _theme = theme ?? widget.theme;
      _actions = actions;
      menuState = state;
      _menuChild = child;
      _menuRenderBox = renderBox;
    }
  }

  void _detachMenu() {
    _pointerDownTimer?.cancel();
    setState(() {
      _pressed = false;
      _pressedAgain = false;
      _tooltip = null;
      _hoveredAction = -1;
      menuState = null;
      _menuRenderBox = null;
      _menuChild = null;
      _menuAttached = false;
      menuVisible = false;
    });
  }

  void _pointerDown(Offset offset) {
    if (!_menuAttached) return;

    if (menuVisible) {
      _pressedAgain = true;
      _pointerMove(offset);
    } else if (!_pressed) {
      _pressed = true;
      _pointerOffset = offset;

      _pointerDownTimer = Timer(_theme.delayDuration, () {
        _pointerUpTimer?.cancel();
        _bounceController.forward(from: 0);
        setState(() {
          menuVisible = true;
          _hoveredAction = -1;
        });
        toggleMenu(true);
        menuState?.setVisibility(false);
      });
    }
  }

  void _pointerUp(Offset offset) {
    _pointerDownTimer?.cancel();

    if (menuVisible && (isOutsideOfPointerArea(offset) || _pressedAgain)) {
      if (_hoveredAction >= 0) {
        _actions[_hoveredAction].onSelect();
      }

      menuState?.setVisibility(true);
      toggleMenu(false);
      setState(() {
        _menuAttached = false;
        menuVisible = false;
      });

      _pointerUpTimer = Timer(_theme.fadeDuration, () {
        _detachMenu();
      });
    }

    _pressed = false;
    _pressedAgain = false;
  }

  void _pointerMove(Offset offset) {
    if (menuVisible) {
      for (int i = 0; i < _actions.length; i++) {
        PieAction action = _actions[i];
        Offset actionOffset = Offset(
          _pointerOffset.dx + _theme.distance * cos(action.angle),
          _pointerOffset.dy - _theme.distance * sin(action.angle),
        );
        if ((actionOffset - offset).distance <
            _theme.buttonSize / 2 + sqrt(_theme.buttonSize)) {
          if (_hoveredAction != i) {
            setState(() {
              _hoveredAction = i;
              _tooltip = action.tooltip;
            });
          }
          return;
        }
      }
      if (_hoveredAction != -1) {
        setState(() => _hoveredAction = -1);
      }
    } else if (_pressed && isOutsideOfPointerArea(offset)) {
      _detachMenu();
    }
  }
}
