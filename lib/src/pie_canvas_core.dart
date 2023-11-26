import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_delegate.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:pie_menu/src/platform/base.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Canvas widget that is actually displayed on the screen.
class PieCanvasCore extends StatefulWidget {
  const PieCanvasCore({
    super.key,
    required this.state,
    required this.onMenuToggle,
    required this.child,
  });

  final PieState state;
  final Function(bool active)? onMenuToggle;
  final Widget child;

  @override
  PieCanvasCoreState createState() => PieCanvasCoreState();
}

class PieCanvasCoreState extends State<PieCanvasCore>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// * [PieMenu] refers to the menu that is currently displayed on the canvas.

  PieState get _state => widget.state;

  /// Theme of [PieMenu].
  ///
  /// If [PieMenu] does not have a theme, [PieCanvas] theme is displayed.
  PieTheme get _theme => _state.theme;

  final _platform = BasePlatform();

  /// Actions of [PieMenu].
  List<PieAction> _actions = [];

  /// Controls [_bounceAnimation].
  late final AnimationController _bounceController = AnimationController(
    duration: _theme.bounceDuration,
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
    if (mounted && _state.active) {
      final prevSize = _size;
      _size = PlatformDispatcher.instance.views.first.physicalSize;
      if (prevSize != _size) {
        _state.update(active: false, forceClose: true);
        _notifyToggleListeners(active: false);
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
    final menuRenderBox = _state.menuRenderBox;

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
              onPointerHover: _state.active
                  ? (event) => _pointerMove(event.position)
                  : null,
              onPointerUp: (event) => _pointerUp(event.position),
              child: IgnorePointer(
                ignoring: _state.active,
                child: widget.child,
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                duration:
                    _state.forceClose ? Duration.zero : _theme.fadeDuration,
                opacity: _state.active ? 1 : 0,
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
                    () {
                      final tooltipAlignment = _theme.tooltipCanvasAlignment;

                      Widget child = AnimatedOpacity(
                        opacity:
                            _state.active && _hoveredAction != null ? 1 : 0,
                        duration: _state.active
                            ? _theme.hoverDuration
                            : Duration.zero,
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
                                .merge(_state.canvasTheme.tooltipTextStyle)
                                .merge(_theme.tooltipTextStyle),
                            child: _tooltip ?? const SizedBox(),
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
                            state: _state,
                            action: _actions[i],
                            angle: _getActionAngle(i),
                            hovered: i == _hoveredAction,
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

  void _notifyToggleListeners({required bool active}) {
    _onMenuToggle?.call(active);
    widget.onMenuToggle?.call(active);
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
    required RenderBox renderBox,
    required Key menuKey,
    required List<PieAction> actions,
    required PieTheme theme,
    required Function(bool menuActive)? onMenuToggle,
  }) {
    _contextMenuSubscription = _platform.listenContextMenu(
      shouldPreventDefault: rightClicked,
    );

    _attachTimer?.cancel();
    _detachTimer?.cancel();

    _onMenuToggle = onMenuToggle;
    _actions = actions;

    _state.update(
      shouldNotify: false,
      theme: theme,
      menuRenderBox: renderBox,
      menuKey: menuKey,
    );

    if (!_pressed) {
      _pressed = true;
      _pointerOffset = offset;

      _attachTimer = Timer(
        rightClicked ? Duration.zero : _theme.delayDuration,
        () {
          _detachTimer?.cancel();
          _bounceController.forward(from: 0);

          _baseAngle = _calculateBaseAngle();
          _hoveredAction = null;

          _state.update(
            active: true,
            theme: theme,
            menuRenderBox: renderBox,
            menuKey: menuKey,
          );
          _notifyToggleListeners(active: true);
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
        _pressed = false;
        _pressedAgain = false;
        _tooltip = null;
        _hoveredAction = null;

        _state.update(active: false);
      },
    );
  }

  void _pointerDown(Offset offset) {
    if (_state.active) {
      _pressedAgain = true;
      _pointerMove(offset);
    }
  }

  void _pointerUp(Offset offset) {
    _attachTimer?.cancel();

    if (_state.active) {
      if (_isBeyondPointerBounds(offset) || _pressedAgain) {
        final hoveredAction = _hoveredAction;

        if (hoveredAction != null) {
          _actions[hoveredAction].onSelect();
        }

        _state.update(active: false);
        _notifyToggleListeners(active: false);

        _detachMenu();
      }
    } else {
      _detachMenu();
    }

    _pressed = false;
    _pressedAgain = false;
  }

  void _pointerMove(Offset offset) {
    if (_state.active) {
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
