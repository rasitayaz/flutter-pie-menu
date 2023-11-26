import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Widget that displays [PieAction]s as circular buttons for its child.
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

  /// Functional callback that is triggered when
  /// this [PieMenuCore] is opened and closed.
  final Function(bool active)? onToggle;

  /// Functional callback that is triggered on press.
  ///
  /// You can also use [onPressedWithDevice] if you need [PointerDeviceKind].
  final Function()? onPressed;

  /// Functional callback with [PointerDeviceKind] details
  /// that is triggered on press.
  ///
  /// Can be useful to distinguish between mouse and touch events.
  final Function(PointerDeviceKind kind)? onPressedWithDevice;

  @override
  State<PieMenuCore> createState() => _PieMenuCoreState();
}

class _PieMenuCoreState extends State<PieMenuCore>
    with SingleTickerProviderStateMixin {
  final _uniqueKey = UniqueKey();

  var _pressedOffset = Offset.zero;
  var _pressedButton = 0;

  late final _fadeController = AnimationController(
    duration: _theme.fadeDuration,
    vsync: this,
  );

  late final _fadeAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _fadeController,
      curve: Curves.ease,
    ),
  );

  PieNotifier get _notifier => PieNotifier.of(context);

  PieState get _state => _notifier.state;

  PieTheme get _theme => widget.theme ?? _notifier.canvasTheme;

  var _previouslyActive = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.menuKey == _uniqueKey) {
      if (!_previouslyActive && _state.active) {
        _fadeController.forward(from: 0);
      } else if (_previouslyActive && !_state.active) {
        _fadeController.reverse();
      }
    } else {
      _fadeController.animateTo(0, duration: Duration.zero);
    }

    _previouslyActive = _state.active;

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
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
            onPointerUp: _pointerUp,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _pointerDown(PointerDownEvent event) async {
    _pressedOffset = event.position;
    _pressedButton = event.buttons;

    if (_state.active) return;

    final isMouseEvent = event.kind == PointerDeviceKind.mouse;
    final leftClicked = isMouseEvent && _pressedButton == kPrimaryMouseButton;
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

    if (leftClicked && !_theme.leftClickShowsMenu) return;

    _notifier.core.attachMenu(
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

  void _pointerUp(PointerUpEvent event) {
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
}
