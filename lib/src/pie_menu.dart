import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_provider.dart';
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
  ///
  /// Can be useful to distinguish between mouse and touch events.
  final Function(PointerDeviceKind kind)? onPressedWithDevice;

  @override
  State<PieMenu> createState() => _PieMenuState();
}

class _PieMenuState extends State<PieMenu> with SingleTickerProviderStateMixin {
  final _uniqueKey = UniqueKey();

  var _pressedOffset = Offset.zero;
  var _pressedButton = 0;

  PieProvider get _provider => PieProvider.of(context);

  PieTheme get _theme => widget.theme ?? _provider.canvasTheme;
  PieState get _state => _provider.state;

  PieCanvasOverlayState get _overlayState => _provider.overlayState;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _pressedOffset = event.position;
          _pressedButton = event.buttons;

          if (_state.active) return;

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

          if (leftClicked && !_theme.leftClickShowsMenu) return;

          _overlayState.attachMenu(
            rightClicked: rightClicked,
            offset: _pressedOffset,
            renderBox: context.findRenderObject() as RenderBox,
            menuKey: _uniqueKey,
            actions: widget.actions,
            theme: widget.theme,
            onMenuToggle: widget.onToggle,
          );

          final recognizer = LongPressGestureRecognizer(
            duration: _theme.delayDuration,
          );
          recognizer.onLongPressUp = () {};
          recognizer.addPointer(event);
        },
        onPointerMove: (event) {
          /* if ((event.position - _pressedOffset).distance >
              _theme.pointerSize / 2) {} */
        },
        onPointerUp: (event) {
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
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _state.active && _state.menuKey == _uniqueKey ? 1 : 0,
                duration: _state.forceClose || _state.menuKey != _uniqueKey
                    ? Duration.zero
                    : _theme.fadeDuration,
                curve: Curves.ease,
                child: ColoredBox(color: _theme.effectiveOverlayColor),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
