import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/bouncing_widget.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_delegate.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';
import 'package:pie_menu/src/platform/base.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Controls functionality and appearance of [PieCanvas].
class PieCanvasCore extends StatefulWidget {
  const PieCanvasCore({
    super.key,
    required this.onMenuToggle,
    required this.theme,
    required this.child,
  });

  final Function(bool menuOpen)? onMenuToggle;
  final PieTheme theme;
  final Widget child;

  @override
  PieCanvasCoreState createState() => PieCanvasCoreState();
}

class PieCanvasCoreState extends State<PieCanvasCore>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// Controls platform-specific functionality, used to handle right-clicks.
  final _platform = BasePlatform();

  /// Controls [_buttonBounceAnimation].
  late final _buttonBounceController = AnimationController(
    duration: _theme.pieBounceDuration,
    vsync: this,
  );

  /// Bouncing animation for the [PieButton]s.
  late final _buttonBounceAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _buttonBounceController,
      curve: Curves.elasticOut,
    ),
  );

  /// Controls [_fadeAnimation].
  late final _fadeController = AnimationController(
    duration: _theme.fadeDuration,
    vsync: this,
  );

  /// Fade animation for the canvas and current menu.
  late final _fadeAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _fadeController,
      curve: Curves.ease,
    ),
  );

  /// Whether menu child is currently pressed.
  var _pressed = false;

  /// Whether menu child is pressed again while a menu is open.
  var _pressedAgain = false;

  /// Current pointer offset.
  var _pointerOffset = Offset.zero;

  /// Pointer offset relative to the menu.
  var _localPointerOffset = Offset.zero;

  /// Initially pressed offset.
  var _pressedOffset = Offset.zero;

  /// Main menu actions list
  var _mainActions = <PieAction>[];

  /// Currently active submenu actions (if any)
  var _submenuActions = <PieAction>[];

  /// Currently active submenu parent index
  int? _hoveredSubmenuParentIndex;

  /// Whether a submenu is currently visible and fully initialized
  bool get _submenuVisible =>
      _hoveredSubmenuParentIndex != null &&
      _hoveredSubmenuParentPosition != null &&
      _submenuActions.isNotEmpty;

  /// Position of the current submenu parent action button
  Offset? _hoveredSubmenuParentPosition;

  /// Flag to track submenu transition state
  bool _isInSubmenuTransition = false;

  /// Last update timestamp for submenu to prevent race conditions
  int _lastSubmenuUpdateTime = 0;

  /// Timer for handling delayed submenu recreation during transitions
  Timer? _submenuTransitionTimer;

  /// Tracks whether we're moving toward the submenu to prevent unwanted closing
  bool _isMovingTowardSubmenu = false;

  /// Tracks the global positions of each action button.
  final _actionPositions = <int, Offset>{};

  /// Starts when the pointer is down,
  /// is triggered after the delay duration specified in [PieTheme],
  /// and gets cancelled when the pointer is up.
  Timer? _attachTimer;

  /// Starts when the pointer is up,
  /// is triggered after the fade duration specified in [PieTheme],
  /// and gets cancelled when the pointer is down again.
  Timer? _detachTimer;

  /// Functional callback triggered when the current menu opens or closes.
  Function(bool menuOpen)? _onMenuToggle;

  /// Tooltip widget of the currently hovered action.
  Widget? _tooltip;

  /// Secondary tooltip widget for submenu actions
  Widget? _submenuTooltip;

  /// Size of the screen. Used to close the menu when the screen size changes.
  var _physicalSize = PlatformDispatcher.instance.views.first.physicalSize;

  /// Theme of the current [PieMenu].
  ///
  /// If the [PieMenu] does not have a theme, [PieCanvas] theme is used.
  late var _theme = widget.theme;

  /// Stream subscription for right-clicks.
  dynamic _contextMenuSubscription;

  /// RenderBox of the current menu.
  RenderBox? _menuRenderBox;

  /// Child widget of the current menu.
  Widget? _menuChild;

  /// Bounce animation for the child widget of the current menu.
  Animation<double>? _childBounceAnimation;

  /// Controls the shared state.
  PieNotifier get _notifier => PieNotifier.of(context);

  /// Current shared state.
  PieState get _state => _notifier.state;

  /// Offset of the canvas relative to the screen.
  var _canvasOffset = Offset.zero;

  /// Offset of the menu relative to the screen.
  var _menuOffset = Offset.zero;

  /// RenderBox of the canvas.
  RenderBox? get _canvasRenderBox {
    final object = context.findRenderObject();
    return object is RenderBox && object.hasSize ? object : null;
  }

  Size get _canvasSize => _canvasRenderBox?.size ?? Size.zero;

  double get cw => _canvasSize.width;
  double get ch => _canvasSize.height;

  double get cx => _canvasOffset.dx;
  double get cy => _canvasOffset.dy;

  double get px => _pointerOffset.dx - cx;
  double get py => _pointerOffset.dy - cy;

  double get _angleDiff {
    final customAngleDiff = _theme.customAngleDiff;
    if (customAngleDiff != null) return customAngleDiff;

    final tangent = (_theme.buttonSize / 2 + _theme.spacing) / _theme.radius;
    final angleInRadians = 2 * asin(tangent);
    return degrees(angleInRadians);
  }

  /// Submenu radius - exactly 2.2x the main menu radius for a perfect concentric circle
  double get _submenuRadius => _theme.radius * 2.2;

  /// Angle difference for submenu items
  double get _submenuAngleDiff {
    // found this manually appealing but we could make it
    // dynamic based on the number of items in the submenu
    return 27.5;
  }

  /// Angle of the first [PieButton] in degrees.
  double get _baseAngle {
    final arc = (_mainActions.length - 1) * _angleDiff;
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

    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final size = mediaQuery.size;

    final cx = this.cx < padding.left ? padding.left : this.cx;
    final cy = this.cy < padding.top ? padding.top : this.cy;
    final cw = this.cx + this.cw > size.width - padding.right
        ? size.width - padding.right - cx
        : this.cw;
    final ch = this.cy + this.ch > size.height - padding.bottom
        ? size.height - padding.bottom - cy
        : this.ch;

    final px = _pointerOffset.dx - cx;
    final py = _pointerOffset.dy - cy;

    final p = Offset(px, py);
    final distanceFactor = min(1, (cw / 2 - px) / (cw / 2));
    final safeDistance = _theme.radius + _theme.buttonSize;

    double angleBetween(Offset o1, Offset o2) {
      final slope = (o2.dy - o1.dy) / (o2.dx - o1.dx);
      return degrees(atan(slope));
    }

    if ((ch >= 2 * safeDistance && py < safeDistance) ||
        (ch < 2 * safeDistance && py < ch / 2)) {
      final o = px < cw / 2 ? const Offset(0, 0) : Offset(cw, 0);
      return arc / 2 - 90 + angleBetween(o, p);
    } else if (py > ch - safeDistance && (px < cw * 2 / 5 || px > cw * 3 / 5)) {
      final o = px < cw / 2 ? Offset(0, ch) : Offset(cw, ch);
      return arc / 2 + 90 + angleBetween(o, p);
    } else {
      return arc / 2 + 90 - 90 * distanceFactor;
    }
  }

  /// Base angle for submenu items - center them around the parent menu item's angle
  double get _submenuBaseAngle {
    if (!_submenuVisible) {
      return _baseAngle;
    }

    final parentIndex = _hoveredSubmenuParentIndex!;
    // Get the exact angle of the parent menu item in radians
    final parentAngle = _getActionAngle(parentIndex);
    // Convert to degrees for easier calculations
    final parentAngleDegrees = degrees(parentAngle);

    // Total angular spread of submenu items
    final totalSpread = (_submenuActions.length - 1) * _submenuAngleDiff;

    // Base angle centered around parent's angle
    double baseAngle = parentAngleDegrees + totalSpread / 2;

    // Check if any submenu items would be out of bounds and adjust if needed
    if (_submenuActions.length > 0) {
      baseAngle = _adjustSubmenuBaseAngleForBounds(baseAngle, totalSpread);
    }

    return baseAngle;
  }

  /// Adjusts the submenu base angle to ensure all items stay within canvas bounds
  double _adjustSubmenuBaseAngleForBounds(
      double baseAngle, double totalSpread) {
    // We'll check each submenu item's position with the current base angle
    final List<Offset> itemPositions = [];
    final List<bool> isOutOfBoundsLeft = [];
    final List<bool> isOutOfBoundsRight = [];

    // Calculate positions for all items with the current base angle
    for (int i = 0; i < _submenuActions.length; i++) {
      // Calculate the angle for this item
      final itemAngle =
          radians(baseAngle - _theme.angleOffset - _submenuAngleDiff * i);

      // Calculate the position
      final itemPosition = Offset(
          _pointerOffset.dx + _submenuRadius * cos(itemAngle),
          _pointerOffset.dy - _submenuRadius * sin(itemAngle));

      itemPositions.add(itemPosition);

      // Check if out of bounds
      isOutOfBoundsLeft.add(itemPosition.dx - _theme.buttonSize / 2 < cx);
      isOutOfBoundsRight.add(itemPosition.dx + _theme.buttonSize / 2 > cx + cw);
    }

    // If any items are out of bounds, we need to adjust
    if (isOutOfBoundsLeft.contains(true) || isOutOfBoundsRight.contains(true)) {
      // Determine which direction to rotate
      final totalOutOfBoundsLeft = isOutOfBoundsLeft.where((b) => b).length;
      final totalOutOfBoundsRight = isOutOfBoundsRight.where((b) => b).length;

      // Default to rotating based on which side has more items out of bounds
      bool rotateClockwise = totalOutOfBoundsLeft > totalOutOfBoundsRight;

      // If all items are on the same side, rotate away from that side
      if (totalOutOfBoundsLeft > 0 && totalOutOfBoundsRight == 0) {
        rotateClockwise = true; // Rotate clockwise to move items right
      } else if (totalOutOfBoundsRight > 0 && totalOutOfBoundsLeft == 0) {
        rotateClockwise = false; // Rotate counterclockwise to move items left
      }

      // Calculate the minimum adjustment needed
      double maxAdjustment = 0;

      for (int i = 0; i < itemPositions.length; i++) {
        final position = itemPositions[i];
        double adjustment = 0;

        // Add a 30px safety margin to ensure items are fully within bounds
        const safetyMargin = 30.0;

        if (isOutOfBoundsLeft[i]) {
          // Calculate how much we need to rotate to move it into bounds
          final distanceOutOfBounds =
              cx - (position.dx - _theme.buttonSize / 2) + safetyMargin;
          final angleToRotate = asin(distanceOutOfBounds / _submenuRadius);
          adjustment = degrees(angleToRotate);
        } else if (isOutOfBoundsRight[i]) {
          // Calculate how much we need to rotate to move it into bounds
          final distanceOutOfBounds =
              (position.dx + _theme.buttonSize / 2) - (cx + cw) + safetyMargin;
          final angleToRotate = asin(distanceOutOfBounds / _submenuRadius);
          adjustment = degrees(angleToRotate);
        }

        maxAdjustment = max(maxAdjustment, adjustment);
      }

      // Apply the adjustment with a small buffer for good measure
      maxAdjustment += 5; // Add 5 degrees buffer

      if (rotateClockwise) {
        baseAngle -= maxAdjustment;
      } else {
        baseAngle += maxAdjustment;
      }
    }

    return baseAngle;
  }

  double _getActionAngle(int index) {
    return radians(_baseAngle - _theme.angleOffset - _angleDiff * index);
  }

  double _getSubmenuActionAngle(int index) {
    if (!_submenuVisible) {
      return 0;
    }

    return radians(_submenuBaseAngle - _submenuAngleDiff * index);
  }

  Offset _getActionOffset(int index) {
    final angle = _getActionAngle(index);
    final offset = Offset(
      _pointerOffset.dx + _theme.radius * cos(angle),
      _pointerOffset.dy - _theme.radius * sin(angle),
    );

    // Track the position of this action button
    _actionPositions[index] = offset;

    return offset;
  }

  Offset _getSubmenuActionOffset(int index) {
    if (!_submenuVisible) {
      return Offset.zero;
    }

    // Get the angle for this submenu item
    final angle = _getSubmenuActionAngle(index);

    // Use the same center point as the main menu (_pointerOffset)
    // But with double the radius to create a perfect concentric circle
    // This ensures consistent spacing and layout
    return Offset(_pointerOffset.dx + _submenuRadius * cos(angle),
        _pointerOffset.dy - _submenuRadius * sin(angle));
  }

  /// Handles submenu transitions with minimal complexity
  void _handleSubmenuTransition({
    required int? newParentIndex,
    bool forceRefresh = false,
  }) {
    // Cancel any pending transitions
    _submenuTransitionTimer?.cancel();

    // If this is the same parent and no refresh is requested, do nothing
    if (!forceRefresh && newParentIndex == _hoveredSubmenuParentIndex) {
      return;
    }

    // If we're just closing the submenu
    if (newParentIndex == null) {
      setState(() {
        _hoveredSubmenuParentIndex = null;
        _hoveredSubmenuParentPosition = null;
        _submenuActions = [];
        _isInSubmenuTransition = false;
        _isMovingTowardSubmenu = false;
      });

      // Clear submenu hover state
      _notifier.update(clearHoveredSubmenuAction: true);
      return;
    }

    // Validation checks
    if (newParentIndex < 0 || newParentIndex >= _mainActions.length) {
      return;
    }

    final action = _mainActions[newParentIndex];
    if (!action.isSubmenu ||
        action.subActions == null ||
        action.subActions!.isEmpty) {
      return;
    }

    // If we're switching between different parent menu items, add a brief delay
    // to prevent visual confusion and ensure correct positioning
    if (_hoveredSubmenuParentIndex != null &&
        _hoveredSubmenuParentIndex != newParentIndex) {
      _isInSubmenuTransition = true;

      // First clear the old submenu
      setState(() {
        _hoveredSubmenuParentIndex = null;
        _hoveredSubmenuParentPosition = null;
        _submenuActions = [];
      });

      // Add a small delay before showing the new one
      _submenuTransitionTimer = Timer(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        // Calculate the position and show the new submenu
        final newParentPosition = _getActionOffset(newParentIndex);

        setState(() {
          _hoveredSubmenuParentIndex = newParentIndex;
          _hoveredSubmenuParentPosition = newParentPosition;
          _submenuActions = action.subActions!;
          _isInSubmenuTransition = false;

          // Clear any hover state on initial submenu display
          _notifier.update(clearHoveredSubmenuAction: true);
        });
      });
    } else {
      // Just show the submenu directly for the initial open (no transition needed)
      final newParentPosition = _getActionOffset(newParentIndex);

      setState(() {
        _hoveredSubmenuParentIndex = newParentIndex;
        _hoveredSubmenuParentPosition = newParentPosition;
        _submenuActions = action.subActions!;
        _isInSubmenuTransition = false;

        // Clear any hover state on initial submenu display
        _notifier.update(clearHoveredSubmenuAction: true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) {
        _canvasOffset =
            _canvasRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_state.menuOpen) {
        setState(() {
          _canvasOffset =
              _canvasRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
          _menuOffset =
              _menuRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _buttonBounceController.dispose();
    _fadeController.dispose();
    _attachTimer?.cancel();
    _detachTimer?.cancel();
    _submenuTransitionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted && _state.menuOpen) {
      final prevSize = _physicalSize;
      _physicalSize = PlatformDispatcher.instance.views.first.physicalSize;
      if (prevSize != _physicalSize) {
        _notifier.update(
          menuOpen: false,
          clearMenuKey: true,
        );
        _notifyToggleListeners(menuOpen: false);
        _detachMenu(animate: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuRenderBox = _menuRenderBox;
    final hoveredAction = _state.hoveredAction;

    // Update tooltip based on hovered action
    if (hoveredAction != null) {
      _tooltip = hoveredAction < _mainActions.length
          ? _mainActions[hoveredAction].tooltip
          : null;
    }

    // Update submenu tooltip
    final hoveredSubmenuAction = _state.hoveredSubmenuAction;
    if (hoveredSubmenuAction != null && _submenuVisible) {
      _submenuTooltip = hoveredSubmenuAction < _submenuActions.length
          ? _submenuActions[hoveredSubmenuAction].tooltip
          : null;
    } else {
      _submenuTooltip = null;
    }

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (_state.menuOpen) {
          setState(() {
            _menuOffset =
                _menuRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
          });
        }
        return false;
      },
      child: Material(
        type: MaterialType.transparency,
        child: MouseRegion(
          cursor: hoveredAction != null || hoveredSubmenuAction != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Stack(
            children: [
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) => _pointerDown(event.position),
                onPointerMove: (event) => _pointerMove(event.position),
                onPointerHover: _state.menuOpen
                    ? (event) => _pointerMove(event.position)
                    : null,
                onPointerUp: (event) => _pointerUp(event.position),
                child: IgnorePointer(
                  ignoring: _state.menuOpen,
                  child: widget.child,
                ),
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: [
                      //* overlay start *//
                      if (menuRenderBox != null && menuRenderBox.attached)
                        ...() {
                          switch (_theme.overlayStyle) {
                            case PieOverlayStyle.around:
                              return [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: OverlayPainter(
                                      color: _theme.effectiveOverlayColor,
                                      menuOffset: Offset(
                                        _menuOffset.dx - cx,
                                        _menuOffset.dy - cy,
                                      ),
                                      menuSize: menuRenderBox.size,
                                    ),
                                  ),
                                ),
                              ];
                            case PieOverlayStyle.behind:
                              final bounceAnimation = _childBounceAnimation;

                              return [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: _theme.effectiveOverlayColor,
                                  ),
                                ),
                                Positioned(
                                  left: _menuOffset.dx - cx,
                                  top: _menuOffset.dy - cy,
                                  child: AnimatedOpacity(
                                    opacity: _state.menuOpen &&
                                            (_state.hoveredAction != null ||
                                                _state.hoveredSubmenuAction !=
                                                    null)
                                        ? _theme.childOpacityOnButtonHover
                                        : 1,
                                    duration: _theme.hoverDuration,
                                    curve: Curves.ease,
                                    child: SizedBox.fromSize(
                                      size: menuRenderBox.size,
                                      child: _theme.childBounceEnabled &&
                                              bounceAnimation != null
                                          ? BouncingWidget(
                                              theme: _theme,
                                              animation: bounceAnimation,
                                              pressedOffset:
                                                  _localPointerOffset,
                                              child: _menuChild ??
                                                  const SizedBox(),
                                            )
                                          : _menuChild,
                                    ),
                                  ),
                                ),
                              ];
                          }
                        }(),
                      //* overlay end *//

                      //* tooltip start *//
                      () {
                        final tooltipAlignment = _theme.tooltipCanvasAlignment;

                        // Tooltip widget
                        Widget tooltipWidget = AnimatedOpacity(
                          opacity: hoveredAction != null ||
                                  hoveredSubmenuAction != null
                              ? 1
                              : 0,
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
                              child: _submenuTooltip ??
                                  _tooltip ??
                                  const SizedBox(),
                            ),
                          ),
                        );

                        if (_theme.tooltipUseFittedBox) {
                          tooltipWidget = FittedBox(child: tooltipWidget);
                        }

                        if (tooltipAlignment != null) {
                          return Align(
                            alignment: tooltipAlignment,
                            child: tooltipWidget,
                          );
                        } else {
                          final mainOffsets = [
                            _pointerOffset,
                            for (var i = 0; i < _mainActions.length; i++)
                              _getActionOffset(i),
                          ];

                          final submenuOffsets = _submenuVisible
                              ? [
                                  _hoveredSubmenuParentPosition!,
                                  for (var i = 0;
                                      i < _submenuActions.length;
                                      i++)
                                    _getSubmenuActionOffset(i),
                                ]
                              : <Offset>[];

                          final allOffsets = [
                            ...mainOffsets,
                            ...submenuOffsets
                          ];

                          double? getTopDistance() {
                            if (py >= ch / 2) return null;

                            final dyMax = allOffsets
                                .map((o) => o.dy)
                                .reduce((dy1, dy2) => max(dy1, dy2));

                            return dyMax - cy + _theme.buttonSize / 2;
                          }

                          double? getBottomDistance() {
                            if (py < ch / 2) return null;

                            final dyMin = allOffsets
                                .map((o) => o.dy)
                                .reduce((dy1, dy2) => min(dy1, dy2));

                            return ch - dyMin + cy + _theme.buttonSize / 2;
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
                              child: tooltipWidget,
                            ),
                          );
                        }
                      }(),
                      //* tooltip end *//

                      //* main menu buttons start *//
                      Flow(
                        delegate: PieDelegate(
                          bounceAnimation: _buttonBounceAnimation,
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
                                            ? Colors.black
                                                .withValues(alpha: 0.35)
                                            : Colors.white
                                                .withValues(alpha: 0.5)),
                                    width: 4,
                                  ),
                                ),
                          ),
                          for (int i = 0; i < _mainActions.length; i++)
                            PieButton(
                              theme: _theme,
                              action: _mainActions[i],
                              angle: _getActionAngle(i),
                              hovered: i == hoveredAction,
                            ),
                        ],
                      ),
                      //* main menu buttons end *//

                      //* submenu buttons start *//
                      if (_submenuVisible)
                        Flow(
                          delegate: PieDelegate.custom(
                            bounceAnimation: _buttonBounceAnimation,
                            // Adding a tiny offset to ensure centerOffset != pointerOffset
                            // This prevents the first submenu item from being positioned at the center
                            centerOffset:
                                _pointerOffset + const Offset(0.001, 0.001),
                            canvasOffset: _canvasOffset,
                            baseAngle: _submenuBaseAngle,
                            angleDiff: _submenuAngleDiff,
                            radius: _submenuRadius, // Use 2x radius directly
                            theme: _theme,
                            applyAngleOffset:
                                false, // Don't apply angleOffset again since it's already in _submenuBaseAngle
                          ),
                          children: [
                            // Add an empty Box as the first child that won't be visible
                            // This ensures all actual menu items are at index > 0 and will be positioned on the circle
                            const SizedBox.shrink(),
                            for (int i = 0; i < _submenuActions.length; i++)
                              PieButton(
                                theme: _theme,
                                action: _submenuActions[i],
                                angle: _getSubmenuActionAngle(i),
                                hovered: i == _state.hoveredSubmenuAction,
                              ),
                          ],
                        ),
                      //* submenu buttons end *//
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _notifyToggleListeners({required bool menuOpen}) {
    _onMenuToggle?.call(menuOpen);
    widget.onMenuToggle?.call(menuOpen);
  }

  bool _isBeyondPointerBounds(Offset offset) {
    return (_pressedOffset - offset).distance > _theme.pointerSize / 2;
  }

  void attachMenu({
    required bool rightClicked,
    required RenderBox renderBox,
    required Widget child,
    required Animation<double>? bounceAnimation,
    required Key menuKey,
    required List<PieAction> actions,
    required PieTheme theme,
    required Function(bool menuOpen)? onMenuToggle,
    required Offset? offset,
    required Alignment? menuAlignment,
    required Offset? menuDisplacement,
  }) {
    assert(
      offset != null || menuAlignment != null,
      'Offset or alignment must be provided.',
    );

    _theme = theme;

    // Reset and initialize all state
    _mainActions = actions;
    _submenuActions = [];
    _hoveredSubmenuParentIndex = null;
    _hoveredSubmenuParentPosition = null;
    _isInSubmenuTransition = false;
    _isMovingTowardSubmenu = false;
    _actionPositions.clear();

    // Cancel any pending submenu transitions
    _submenuTransitionTimer?.cancel();

    _contextMenuSubscription = _platform.listenContextMenu(
      shouldPreventDefault: rightClicked,
    );

    _attachTimer?.cancel();
    _detachTimer?.cancel();

    if (!_pressed) {
      _pressed = true;

      menuAlignment ??= _theme.menuAlignment;
      menuDisplacement ??= _theme.menuDisplacement;

      if (menuAlignment != null) {
        _pointerOffset = renderBox.localToGlobal(
          renderBox.size.center(
            Offset(
              menuAlignment.x * renderBox.size.width / 2,
              menuAlignment.y * renderBox.size.height / 2,
            ),
          ),
        );
      } else if (offset != null) {
        _pointerOffset = offset;
      }

      _pointerOffset += menuDisplacement;
      _pressedOffset = offset ?? _pointerOffset;
      _localPointerOffset = renderBox.globalToLocal(_pointerOffset);

      _attachTimer = Timer(
        rightClicked ? Duration.zero : _theme.delayDuration,
        () {
          _detachTimer?.cancel();

          _buttonBounceController.forward(from: 0);
          _fadeController.forward(from: 0);

          _menuRenderBox = renderBox;
          _menuOffset = renderBox.localToGlobal(Offset.zero);
          _menuChild = child;
          _childBounceAnimation = bounceAnimation;
          _onMenuToggle = onMenuToggle;
          _tooltip = null;
          _submenuTooltip = null;

          _notifier.update(
            menuOpen: true,
            menuKey: menuKey,
            clearHoveredAction: true,
            clearHoveredSubmenuAction: true,
          );

          _notifyToggleListeners(menuOpen: true);
        },
      );
    }
  }

  /// Closes the currently attached menu if the given [menuKey] matches.
  void closeMenu(Key menuKey) {
    if (menuKey == _notifier.state.menuKey) {
      _detachMenu();
    }
  }

  void _detachMenu({bool animate = true}) {
    final subscription = _contextMenuSubscription;
    if (subscription is StreamSubscription) subscription.cancel();

    // Cancel any pending submenu transitions
    _submenuTransitionTimer?.cancel();

    if (animate) {
      _fadeController.reverse();
    } else {
      _fadeController.animateTo(0, duration: Duration.zero);
    }

    _detachTimer = Timer(
      animate ? _theme.fadeDuration : Duration.zero,
      () {
        _attachTimer?.cancel();
        _pressed = false;
        _pressedAgain = false;

        // Clear submenu state properly
        _hoveredSubmenuParentIndex = null;
        _hoveredSubmenuParentPosition = null;
        _submenuActions = [];
        _isInSubmenuTransition = false;

        _notifier.update(
          clearMenuKey: true,
          menuOpen: false,
          clearHoveredAction: true,
          clearHoveredSubmenuAction: true,
        );
      },
    );
  }

  void _pointerDown(Offset offset) {
    if (_state.menuOpen) {
      _pressedAgain = true;
      _pointerMove(offset);
    }
  }

  void _pointerUp(Offset offset) {
    _attachTimer?.cancel();

    if (_state.menuOpen) {
      if (_pressedAgain || _isBeyondPointerBounds(offset)) {
        final hoveredAction = _state.hoveredAction;
        final hoveredSubmenuAction = _state.hoveredSubmenuAction;

        // Check if submenu action is hovered
        if (hoveredSubmenuAction != null && _submenuVisible) {
          // Execute the submenu action
          _submenuActions[hoveredSubmenuAction].onSelect();

          // Close the menu
          _notifier.update(menuOpen: false);
          _notifyToggleListeners(menuOpen: false);
          _detachMenu();
        }
        // Otherwise check if main action is hovered
        else if (hoveredAction != null) {
          final action = _mainActions[hoveredAction];

          // If it's not a submenu action (or already showing submenu), execute it
          if (!action.isSubmenu ||
              hoveredAction == _hoveredSubmenuParentIndex) {
            action.onSelect();

            // Close the menu
            _notifier.update(menuOpen: false);
            _notifyToggleListeners(menuOpen: false);
            _detachMenu();
          }
        } else {
          // No action hovered, close the menu
          _notifier.update(menuOpen: false);
          _notifyToggleListeners(menuOpen: false);
          _detachMenu();
        }
      }
    } else {
      _detachMenu();
    }

    _pressed = false;
    _pressedAgain = false;
    _pressedOffset = _pointerOffset;
  }

  void _pointerMove(Offset offset) {
    if (_state.menuOpen) {
      // 1. Determine which main menu action is hovered
      final hoveredMainAction = _checkMainMenuHover(offset);

      // 2. Check if we're hovering over a submenu item
      int? hoveredSubmenuAction = null;
      if (_submenuVisible && !_isInSubmenuTransition) {
        hoveredSubmenuAction = _checkSubmenuHover(offset);

        // If we're hovering over a submenu item, or moving toward the submenu
        if (hoveredSubmenuAction != null) {
          _isMovingTowardSubmenu = true;
        }
      }

      // 3. Check if the hovered main action has a submenu
      final hasSubmenu = hoveredMainAction != null &&
          _mainActions[hoveredMainAction].isSubmenu &&
          _mainActions[hoveredMainAction].subActions != null &&
          _mainActions[hoveredMainAction].subActions!.isNotEmpty;

      // 4. Handle submenu open/close logic
      if (hoveredMainAction != _hoveredSubmenuParentIndex) {
        // If we're hovering a new menu item with a submenu, show it
        if (hasSubmenu) {
          _isMovingTowardSubmenu = false;
          _handleSubmenuTransition(newParentIndex: hoveredMainAction);
        }
        // If we moved away from the parent menu item
        else if (_hoveredSubmenuParentIndex != null) {
          // Only close the submenu if not hovering a submenu item and not moving toward it
          if (hoveredSubmenuAction == null) {
            // Check if we're moving toward the submenu
            final isMovingTowardSubmenu = _isHeadingTowardSubmenu(offset);

            // Only close if we're definitely not going to the submenu
            if (!isMovingTowardSubmenu && !_isMovingTowardSubmenu) {
              _handleSubmenuTransition(newParentIndex: null);
            }
          }
        }
      }

      // 5. Update the global state with hover information
      _notifier.update(
        hoveredAction: hoveredMainAction,
        hoveredSubmenuAction: hoveredSubmenuAction,
        clearHoveredAction: hoveredMainAction == null,
        clearHoveredSubmenuAction: hoveredSubmenuAction == null,
      );

      // Reset flag if no longer hovering submenu item
      if (hoveredSubmenuAction == null && !_isHeadingTowardSubmenu(offset)) {
        _isMovingTowardSubmenu = false;
      }
    } else if (_pressed && _isBeyondPointerBounds(offset)) {
      _detachMenu(animate: false);
    }
  }

  // Checks if the pointer is moving in the direction of the submenu
  bool _isHeadingTowardSubmenu(Offset currentPosition) {
    if (!_submenuVisible || _hoveredSubmenuParentPosition == null) {
      return false;
    }

    // Calculate the submenu center as an average of all positions
    Offset submenuCenter = _hoveredSubmenuParentPosition!;
    if (_submenuActions.isNotEmpty) {
      double sumX = 0, sumY = 0;
      for (int i = 0; i < _submenuActions.length; i++) {
        final pos = _getSubmenuActionOffset(i);
        sumX += pos.dx;
        sumY += pos.dy;
      }
      submenuCenter =
          Offset(sumX / _submenuActions.length, sumY / _submenuActions.length);
    }

    // Get vector from parent item to submenu center
    final submenuDirection = submenuCenter - _hoveredSubmenuParentPosition!;

    // Get vector from parent item to current pointer
    final pointerDirection = currentPosition - _hoveredSubmenuParentPosition!;

    // Check if these vectors are pointing in a similar direction
    // by using the dot product and checking if it's positive
    final dotProduct = submenuDirection.dx * pointerDirection.dx +
        submenuDirection.dy * pointerDirection.dy;

    return dotProduct > 0;
  }

  // Check if the pointer is hovering over a main menu action
  int? _checkMainMenuHover(Offset offset) {
    // Check if pointer is within the menu range
    final withinSafeDistance = (_pressedOffset - offset).distance < 8;

    if (_pressedOffset != _pointerOffset && !withinSafeDistance) {
      _pressedOffset = _pointerOffset;
    }

    final pointerDistance = (_pointerOffset - offset).distance;

    if (withinSafeDistance ||
        pointerDistance < _theme.radius - _theme.buttonSize * 0.5 ||
        pointerDistance > _theme.radius + _theme.buttonSize * 0.8) {
      return null;
    } else {
      var closestDistance = double.infinity;
      var closestAction = 0;

      for (var i = 0; i < _mainActions.length; i++) {
        final actionOffset = _getActionOffset(i);
        final distance = (actionOffset - offset).distance;
        if (distance < closestDistance) {
          closestDistance = distance;
          closestAction = i;
        }
      }

      return closestDistance < _theme.buttonSize * 0.8 ? closestAction : null;
    }
  }

  // Check if the pointer is hovering over a submenu action
  int? _checkSubmenuHover(Offset offset) {
    if (!_submenuVisible || _isInSubmenuTransition) {
      return null;
    }

    // Use a larger hit target for submenu items to make them easier to select
    final hitTargetSize = _theme.buttonSize * 1.2;

    // Check each submenu item individually
    var closestDistance = double.infinity;
    var closestAction =
        -1; // Start with -1 to ensure we find an actual closest item

    for (var i = 0; i < _submenuActions.length; i++) {
      final actionOffset = _getSubmenuActionOffset(i);
      final distance = (actionOffset - offset).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestAction = i;
      }
    }

    // Make sure we found a valid item and it's within hitTargetSize/2 radius
    if (closestAction >= 0 && closestDistance < hitTargetSize / 2) {
      return closestAction;
    }

    return null;
  }

  /// Method to get the appropriate PieTheme based on context
  PieTheme _getThemeForSubmenu() {
    // Create a copy of the current theme with modified radius
    // Need to consider all the properties because PieTheme doesn't have a proper copyWith method
    return PieTheme(
      brightness: _theme.brightness,
      overlayColor: _theme.overlayColor,
      pointerColor: _theme.pointerColor,
      pointerDecoration: _theme.pointerDecoration,
      buttonTheme: _theme.buttonTheme,
      buttonThemeHovered: _theme.buttonThemeHovered,
      iconSize: _theme.iconSize,
      radius: _submenuRadius, // Use our submenu radius
      spacing: _theme.spacing,
      customAngleDiff: _theme.customAngleDiff,
      angleOffset: _theme.angleOffset,
      customAngle: _theme.customAngle,
      customAngleAnchor: _theme.customAngleAnchor,
      menuAlignment: _theme.menuAlignment,
      menuDisplacement: _theme.menuDisplacement,
      buttonSize: _theme.buttonSize,
      pointerSize: _theme.pointerSize,
      tooltipPadding: _theme.tooltipPadding,
      tooltipTextStyle: _theme.tooltipTextStyle,
      tooltipTextAlign: _theme.tooltipTextAlign,
      tooltipCanvasAlignment: _theme.tooltipCanvasAlignment,
      tooltipUseFittedBox: _theme.tooltipUseFittedBox,
      pieBounceDuration: _theme.pieBounceDuration,
      childBounceEnabled: _theme.childBounceEnabled,
      childTiltEnabled: _theme.childTiltEnabled,
      childBounceDuration: _theme.childBounceDuration,
      childBounceFactor: _theme.childBounceFactor,
      childBounceCurve: _theme.childBounceCurve,
      childBounceReverseCurve: _theme.childBounceReverseCurve,
      childBounceFilterQuality: _theme.childBounceFilterQuality,
      fadeDuration: _theme.fadeDuration,
      hoverDuration: _theme.hoverDuration,
      delayDuration: _theme.delayDuration,
      leftClickShowsMenu: _theme.leftClickShowsMenu,
      rightClickShowsMenu: _theme.rightClickShowsMenu,
      overlayStyle: _theme.overlayStyle,
      childOpacityOnButtonHover: _theme.childOpacityOnButtonHover,
    );
  }

  // Get angle for main menu action
  double _getMainActionAngle(int index) {
    // Calculate angle based on index and total number of main actions
    final angleDiff = 2 * pi / _mainActions.length;
    return _baseAngle + (index * angleDiff);
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
    final paint = Paint();
    paint.color = color;

    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addRect(menuOffset & menuSize);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
