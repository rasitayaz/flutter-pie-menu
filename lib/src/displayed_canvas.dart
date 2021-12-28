import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_menu/src/action.dart';
import 'package:pie_menu/src/button.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/delegate.dart';
import 'package:pie_menu/src/menu.dart';
import 'package:pie_menu/src/theme.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// This widget provides a global [DisplayedCanvasState] key
/// for the [PieMenu]s that inherit a [PieCanvas].
class InheritedCanvas extends InheritedWidget {
  InheritedCanvas({
    Key? key,
    required Widget child,
    required PieTheme theme,
    Function(bool menuVisible)? onMenuToggle,
    required this.canvasKey,
  }) : super(
          key: key,
          child: DisplayedCanvas(
            key: canvasKey,
            theme: theme,
            onMenuToggle: onMenuToggle,
            child: child,
          ),
        );

  /// [PieMenu] can control the appearance of the menu
  /// displayed on the [PieCanvas] using this key.
  final GlobalKey<DisplayedCanvasState> canvasKey;

  static InheritedCanvas? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedCanvas>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

/// Canvas widget that is actually displayed on the screen.
class DisplayedCanvas extends StatefulWidget {
  const DisplayedCanvas({
    Key? key,
    required this.theme,
    required this.child,
    this.onMenuToggle,
  }) : super(key: key);

  final Widget child;
  final PieTheme theme;
  final Function(bool menuVisible)? onMenuToggle;

  @override
  DisplayedCanvasState createState() => DisplayedCanvasState();
}

class DisplayedCanvasState extends State<DisplayedCanvas>
    with SingleTickerProviderStateMixin {
  /// * [PieMenu] refers to the menu that is currently displayed on the canvas.

  /// Theme of the [PieMenu].
  ///
  /// If [PieMenu] does not have a theme, [PieCanvas] theme is displayed.
  late PieTheme _theme;

  /// Actions of the [PieMenu].
  late List<PieAction> _actions;

  /// Controls [_bounceAnimation].
  late AnimationController _controller;

  /// Bouncing animation for the [PieButton]s.
  late Animation _bounceAnimation;

  /// Whether the [_menuChild] is currently pressed.
  late bool _pressed;

  /// Whether the [PieMenu] is currently visible.
  late bool _visible;

  /// Child widget of the [PieMenu].
  Widget? _menuChild;

  /// Render box of the [_menuChild].
  RenderBox? _menuRenderBox;

  /// Size of the [_menuChild].
  Size? get _menuSize => _menuRenderBox?.size;

  /// Offset of the [_menuChild].
  Offset get _menuOffset => _menuRenderBox!.localToGlobal(Offset.zero);

  /// Currently pressed pointer offset.
  late Offset _pressedOffset;

  /// Currently hovered [PieButton] index.
  late int _hoveredAction;

  /// Starts when the pointer is down,
  /// is triggered after [_theme.delayDuration],
  /// and gets cancelled when the pointer is up.
  Timer? _pointerDownTimer;

  /// Tooltip text for the hovered [PieButton].
  String? _hoveredTooltip;

  /// Functional callback that is triggered when
  /// the active [PieMenu] is opened and closed.
  Function(bool menuVisible)? _onActiveMenuToggle;

  RenderBox? get _renderBox {
    RenderObject? renderObject = context.findRenderObject();
    return renderObject == null
        ? null
        : context.findRenderObject() as RenderBox;
  }

  Offset get _canvasOffset {
    return _renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
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
    _theme = widget.theme;
    _pressed = false;
    _visible = false;
    _pressedOffset = Offset.zero;
    _hoveredAction = -1;
    _actions = [];

    _controller = AnimationController(
      duration: widget.theme.bounceDuration,
      vsync: this,
    );

    _bounceAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double get _topPadding => MediaQuery.of(context).padding.top;
  double get _screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    double angleDifference = 7.4 * _theme.buttonSize / sqrt(_theme.distance);
    double arc = (_actions.length - 1) * angleDifference;
    double dxRatio = _pressedOffset.dx / _screenWidth;
    double baseAngle = _pressedOffset.dy - _canvasOffset.dy >
            _theme.distance + _theme.buttonSize + _topPadding
        ? (arc / 2) + 180 * dxRatio
        : (arc / 2) - 180 * dxRatio;

    for (int i = 0; i < _actions.length; i++) {
      _actions[i].angle = radians(baseAngle - angleDifference * i);
    }

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          widget.child,
          IgnorePointer(
            child: AnimatedOpacity(
              duration: _theme.fadeDuration,
              opacity: _visible ? 1 : 0,
              curve: Curves.ease,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: _overlayColor,
                    ),
                  ),
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
                  _buildTooltipText(),
                  Flow(
                    delegate: PieDelegate(
                      bounceAnimation: _bounceAnimation,
                      pointerOffset: _pressedOffset,
                      canvasOffset: _canvasOffset,
                      baseAngle: baseAngle,
                      angleDifference: angleDifference,
                      theme: _theme,
                    ),
                    children: [
                      Container(
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
                          menuOpen: _pressed,
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

  Widget _buildTooltipText() {
    double top;
    double dx = _pressedOffset.dx - _canvasOffset.dx;
    double dy = _pressedOffset.dy - _canvasOffset.dy;
    if (dy <
        _theme.distance +
            _theme.buttonSize +
            _tooltipHeight +
            _theme.tooltipPadding +
            _topPadding) {
      top = dy + _theme.distance + _theme.buttonSize;
    } else {
      top = dy - _theme.distance - _theme.buttonSize - _tooltipHeight;
    }

    return Positioned(
      top: top,
      child: SizedBox(
        width: _screenWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _theme.tooltipPadding),
          child: SizedBox(
            height: _tooltipHeight,
            child: Row(
              mainAxisAlignment: dx < _screenWidth / 2
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (_tooltip != null && _tooltip!.isNotEmpty)
                  Flexible(
                    child: FittedBox(
                      child: AnimatedOpacity(
                        opacity: _hoveredAction >= 0 ? 1 : 0,
                        duration: _theme.hoverDuration,
                        curve: Curves.ease,
                        child: Text(
                          _tooltip!,
                          style: _tooltipStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _tooltip {
    if (_hoveredAction >= 0) {
      _hoveredTooltip = _actions[_hoveredAction].tooltip;
    }

    return _hoveredTooltip;
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

  double get _tooltipHeight {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _hoveredTooltip, style: _tooltipStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size.height;
  }

  void toggleMenu(bool menuVisible) {
    if (_onActiveMenuToggle != null) {
      _onActiveMenuToggle!(menuVisible);
    }
    if (widget.onMenuToggle != null) {
      widget.onMenuToggle!(menuVisible);
    }
    if (menuVisible) {
      WidgetsBinding.instance!.addPostFrameCallback((duration) {
        /// This rebuild prevents menu child being displayed
        /// in the wrong offset when the scrollable swiped fast.
        setState(() {});
      });
    }
  }

  bool isOutsideOfPointerArea(Offset offset) {
    return (_pressedOffset - offset).distance > _theme.pointerSize / 2;
  }

  void pointerDown({
    required Widget child,
    required RenderBox renderBox,
    required Offset offset,
    required List<PieAction> actions,
    Function(bool menuVisible)? onMenuToggle,
    PieTheme? theme,
  }) {
    if (_visible) {
      pointerMove(offset);
    } else if (!_pressed) {
      _onActiveMenuToggle = onMenuToggle;
      _theme = theme ?? widget.theme;
      _actions = actions;
      _pressed = true;
      _pressedOffset = offset;
      _pointerDownTimer = Timer(_theme.delayDuration, () {
        _controller.forward(from: 0);
        setState(() {
          _visible = true;
          _hoveredAction = -1;
          _menuChild = child;
          _menuRenderBox = renderBox;
        });
        toggleMenu(true);
      });
    }
  }

  void pointerUp(Offset offset) {
    _pressed = false;
    if (_pointerDownTimer != null) {
      _pointerDownTimer!.cancel();
    }

    if (_visible && isOutsideOfPointerArea(offset)) {
      if (_hoveredAction >= 0) {
        _actions[_hoveredAction].onSelect();
        Future.delayed(_theme.fadeDuration, () {
          _hoveredTooltip = null;
        });
      }

      _visible = false;
      setState(() {});
      toggleMenu(false);
    }
  }

  void pointerMove(Offset offset) {
    if (_visible) {
      for (int i = 0; i < _actions.length; i++) {
        PieAction action = _actions[i];
        Offset actionOffset = Offset(
          _pressedOffset.dx + _theme.distance * cos(action.angle),
          _pressedOffset.dy - _theme.distance * sin(action.angle),
        );
        if ((actionOffset - offset).distance <
            _theme.buttonSize / 2 + sqrt(_theme.buttonSize)) {
          if (_hoveredAction != i) {
            setState(() => _hoveredAction = i);
          }
          return;
        }
      }
      if (_hoveredAction != -1) {
        setState(() => _hoveredAction = -1);
      }
    } else if (_pressed && isOutsideOfPointerArea(offset)) {
      pointerUp(offset);
    }
  }

  void setMenuRenderBox(RenderBox renderBox) {
    setState(() => _menuRenderBox = renderBox);
  }
}
