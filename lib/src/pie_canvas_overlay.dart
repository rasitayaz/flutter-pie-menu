import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_delegate.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:pie_menu/src/platform/base.dart';
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
  final Function(bool active)? onMenuToggle;
  final Widget child;

  @override
  PieCanvasOverlayState createState() => PieCanvasOverlayState();
}

class PieCanvasOverlayState extends State<PieCanvasOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// * [PieMenu] refers to the menu that is currently displayed on the canvas.

  final _platform = BasePlatform();

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
  ).animate(
    CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ),
  );

  /// Whether menu child is currently pressed.
  bool _pressed = false;

  /// Whether menu child is pressed again when the menu is active.
  bool _pressedAgain = false;

  /// Whether [PieMenu] is currently active.
  bool menuActive = false;

  /// Whether a [PieMenu] is attached.
  bool _menuAttached = false;

  /// State of [PieMenu].
  PieMenuState? _menuState;

  /// Render box of menu child.
  RenderBox? _menuRenderBox;

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

  /// Tooltip widget for the hovered [PieButton].
  Widget? _tooltip;

  /// Functional callback that is triggered when
  /// the active [PieMenu] is opened and closed.
  Function(bool active)? _onMenuToggle;

  var forceClose = false;

  RenderBox? get _renderBox {
    final object = context.findRenderObject();
    return object is RenderBox && object.hasSize ? object : null;
  }

  Offset get _canvasOffset {
    return _renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Size get _canvasSize => _renderBox?.size ?? Size.zero;
  double get cw => _canvasSize.width;
  double get ch => _canvasSize.height;

  dynamic _contextMenuSubscription;

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

  var _size = PlatformDispatcher.instance.views.first.physicalSize;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted && menuActive) {
      final prevSize = _size;
      _size = PlatformDispatcher.instance.views.first.physicalSize;
      if (prevSize != _size) {
        setState(() {
          menuActive = false;
          forceClose = true;
        });
        _notifyMenuState(active: false);
        _detachMenu();
      }
    }
  }

  double get px => _pointerOffset.dx - _canvasOffset.dx;
  double get py => _pointerOffset.dy - _canvasOffset.dy;

  double get _angleDiff {
    final customAngleDiff = _theme.customAngleDiff;
    if (customAngleDiff != null) return customAngleDiff;

    final tangent = (_theme.buttonSize / 2 + _theme.spacing) / _theme.radius;
    final angleInRadians = 2 * asin(tangent);
    return degrees(angleInRadians);
  }

  double get _safeDistance => _theme.radius + _theme.buttonSize;

  var _baseAngle = 0.0;

  double _getActionAngle(int index) {
    return radians(_baseAngle - _theme.angleOffset - _angleDiff * index);
  }

  Offset _getActionOffset(int index) {
    final angle = _getActionAngle(index);
    return Offset(
      _pointerOffset.dx + _theme.radius * cos(angle),
      _pointerOffset.dy - _theme.radius * sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _tooltip;
    final menuRenderBox = _menuRenderBox;

    return Material(
      type: MaterialType.transparency,
      child: MouseRegion(
        cursor: _hoveredAction != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) => _pointerDown(event.position),
              onPointerMove: (event) => _pointerMove(event.position),
              onPointerHover:
                  menuActive ? (event) => _pointerMove(event.position) : null,
              onPointerUp: (event) => _pointerUp(event.position),
              child: IgnorePointer(
                ignoring: menuActive,
                child: widget.child,
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                duration: forceClose ? Duration.zero : _theme.fadeDuration,
                opacity: menuActive ? 1 : 0,
                curve: Curves.ease,
                child: Stack(
                  children: [
                    //* overlay start *//
                    if (menuRenderBox != null && menuRenderBox.attached)
                      () {
                        final menuOffset =
                            menuRenderBox.localToGlobal(Offset.zero);

                        return Positioned.fill(
                          child: CustomPaint(
                            painter: OverlayPainter(
                              color: _theme.effectiveOverlayColor,
                              menuOffset: Offset(
                                menuOffset.dx - _canvasOffset.dx,
                                menuOffset.dy - _canvasOffset.dy,
                              ),
                              menuSize: menuRenderBox.size,
                            ),
                          ),
                        );
                      }.call(),
                    //* overlay end *//

                    //* tooltip start *//
                    if (tooltip != null)
                      () {
                        final tooltipAlignment = _theme.tooltipCanvasAlignment;

                        Widget child = AnimatedOpacity(
                          opacity: menuActive && _hoveredAction != null ? 1 : 0,
                          duration: _theme.hoverDuration,
                          curve: Curves.ease,
                          child: Padding(
                            padding: _theme.tooltipPadding,
                            child: DefaultTextStyle.merge(
                              textAlign: _theme.tooltipTextAlign ??
                                  (px < cw / 2
                                      ? TextAlign.right
                                      : TextAlign.left),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _theme.brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              )
                                  .merge(widget.theme.tooltipTextStyle)
                                  .merge(_theme.tooltipTextStyle),
                              child: tooltip,
                            ),
                          ),
                        );

                        if (_theme.tooltipUseFittedBox) {
                          child = FittedBox(child: child);
                        }

                        if (tooltipAlignment != null) {
                          return Align(
                            alignment: tooltipAlignment,
                            child: child,
                          );
                        } else {
                          final offsets = [
                            _pointerOffset,
                            for (var i = 0; i < _actions.length; i++)
                              _getActionOffset(i),
                          ];

                          double? getTopDistance() {
                            if (py >= ch / 2) return null;

                            final dyMax = offsets
                                .map((o) => o.dy)
                                .reduce((dy1, dy2) => max(dy1, dy2));

                            return dyMax -
                                _canvasOffset.dy +
                                _theme.buttonSize / 2;
                          }

                          double? getBottomDistance() {
                            if (py < ch / 2) return null;

                            final dyMin = offsets
                                .map((o) => o.dy)
                                .reduce((dy1, dy2) => min(dy1, dy2));

                            return ch -
                                dyMin +
                                _canvasOffset.dy +
                                _theme.buttonSize / 2;
                          }

                          return Positioned(
                            top: getTopDistance(),
                            bottom: getBottomDistance(),
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: px < cw / 2
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: child,
                            ),
                          );
                        }
                      }.call(),
                    //* tooltip end *//

                    //* action buttons start *//
                    Flow(
                      delegate: PieDelegate(
                        bounceAnimation: _bounceAnimation,
                        pointerOffset: _pointerOffset,
                        canvasOffset: _canvasOffset,
                        baseAngle: _baseAngle,
                        angleDiff: _angleDiff,
                        theme: _theme,
                      ),
                      children: [
                        DecoratedBox(
                          decoration: _theme.pointerDecoration ??
                              BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _theme.pointerColor ??
                                      (_theme.brightness == Brightness.light
                                          ? Colors.black.withOpacity(0.35)
                                          : Colors.white.withOpacity(0.5)),
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
                    //* action buttons end *//
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _notifyMenuState({required bool active}) {
    _onMenuToggle?.call(active);
    widget.onMenuToggle?.call(active);
    print('menu state: $active');
    _menuState?.setState(() {});
    if (active) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        /// This rebuild prevents menu child being displayed
        /// in the wrong offset when the scrollable swiped fast.
        setState(() {});
      });
    }
  }

  bool _isBeyondPointerBounds(Offset offset) {
    return (_pointerOffset - offset).distance > _theme.pointerSize / 2;
  }

  double _angleBetween(Offset o1, Offset o2) {
    final slope = (o2.dy - o1.dy) / (o2.dx - o1.dx);
    return degrees(atan(slope));
  }

  double _calculateBaseAngle() {
    final arc = (_actions.length - 1) * _angleDiff;
    final customAngle = _theme.customAngle;

    if (customAngle != null) {
      switch (_theme.customAngleAnchor) {
        case PieAnchor.start:
          return customAngle;
        case PieAnchor.center:
          return customAngle + arc / 2;
        case PieAnchor.end:
          return customAngle + arc;
      }
    }

    final p = Offset(px, py);
    final distanceFactor = min(1, (cw / 2 - px) / (cw / 2));

    if ((ch >= 2 * _safeDistance && py < _safeDistance) ||
        (ch < 2 * _safeDistance && py < ch / 2)) {
      final o = px < cw / 2 ? const Offset(0, 0) : Offset(cw, 0);
      return arc / 2 - 90 + _angleBetween(o, p);
    } else if (py > ch - _safeDistance &&
        (px < cw * 2 / 5 || px > cw * 3 / 5)) {
      final o = px < cw / 2 ? Offset(0, ch) : Offset(cw, ch);
      return arc / 2 + 90 + _angleBetween(o, p);
    } else {
      return arc / 2 + 90 - 90 * distanceFactor;
    }
  }

  void attachMenu({
    required bool rightClicked,
    required Offset offset,
    required PieMenuState state,
    required Widget child,
    required RenderBox renderBox,
    required List<PieAction> actions,
    required PieTheme? theme,
    required Function(bool menuActive)? onMenuToggle,
  }) {
    _contextMenuSubscription = _platform.listenContextMenu(
      shouldPreventDefault: rightClicked,
    );

    _attachTimer?.cancel();
    _detachTimer?.cancel();
    _menuState?.setChildVisibility(true);

    _menuAttached = true;
    _onMenuToggle = onMenuToggle;
    _theme = theme ?? widget.theme;
    _actions = actions;
    print('new menu state');
    _menuState = state;
    _menuRenderBox = renderBox;

    if (!_pressed) {
      _pressed = true;
      _pointerOffset = offset;

      _attachTimer = Timer(
        rightClicked ? Duration.zero : _theme.delayDuration,
        () {
          _detachTimer?.cancel();
          _bounceController.forward(from: 0);
          setState(() {
            forceClose = false;
            _baseAngle = _calculateBaseAngle();
            menuActive = true;
            _hoveredAction = null;
          });
          print('notify from attach menu');
          _notifyMenuState(active: true);

          Future.delayed(_theme.fadeDuration, () {
            if (!(_detachTimer?.isActive ?? false)) {
              _menuState?.setChildVisibility(false);
            }
          });
        },
      );
    }
  }

  void _detachMenu({bool afterDelay = true}) {
    final subscription = _contextMenuSubscription;
    if (subscription is StreamSubscription) subscription.cancel();

    _detachTimer = Timer(
      afterDelay ? _theme.fadeDuration : Duration.zero,
      () {
        _attachTimer?.cancel();
        if (_menuAttached) {
          setState(() {
            forceClose = false;
            _pressed = false;
            _pressedAgain = false;
            _tooltip = null;
            _hoveredAction = null;
            _menuState = null;
            _menuRenderBox = null;
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
      if (_isBeyondPointerBounds(offset) || _pressedAgain) {
        final hoveredAction = _hoveredAction;

        if (hoveredAction != null) {
          _actions[hoveredAction].onSelect();
        }

        setState(() => menuActive = false);
        print('notify from pointer up');
        _notifyMenuState(active: false);

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
      void hover(int? action) {
        if (_hoveredAction != action) {
          setState(() {
            _hoveredAction = action;
            if (action != null) {
              _tooltip = _actions[action].tooltip;
            }
          });
        }
      }

      final pointerDistance = (_pointerOffset - offset).distance;

      if (pointerDistance < _theme.radius - _theme.buttonSize * 0.5 ||
          pointerDistance > _theme.radius + _theme.buttonSize * 0.8) {
        hover(null);
      } else {
        var closestDistance = double.infinity;
        var closestAction = 0;

        for (var i = 0; i < _actions.length; i++) {
          final actionOffset = _getActionOffset(i);
          final distance = (actionOffset - offset).distance;
          if (distance < closestDistance) {
            closestDistance = distance;
            closestAction = i;
          }
        }

        hover(closestDistance < _theme.buttonSize * 0.8 ? closestAction : null);
      }
    } else if (_pressed && _isBeyondPointerBounds(offset)) {
      _detachMenu(afterDelay: false);
    }
  }
}

class OverlayPainter extends CustomPainter {
  const OverlayPainter({
    required this.color,
    required this.menuOffset,
    required this.menuSize,
  });

  final Color color;
  final Offset menuOffset;
  final Size menuSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRect(menuOffset & menuSize)
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
