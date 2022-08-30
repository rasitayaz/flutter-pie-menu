import 'package:flutter/material.dart';
import 'package:pie_menu/src/displayed_canvas.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Widget that displays [PieAction]s as circular buttons for its child.
class PieMenu extends StatefulWidget {
  const PieMenu({
    super.key,
    this.theme,
    required this.child,
    this.actions = const [],
    this.onToggle,
    this.visibleMenuChild,
  });

  /// Theme to use for this menu, overrides [PieCanvas] theme.
  final PieTheme? theme;

  /// Actions to display as [PieButton]s on the [PieCanvas].
  final List<PieAction> actions;

  /// Widget to be displayed when the menu is hidden.
  final Widget child;

  /// Widget to be displayed when the menu is visible.
  final Widget? visibleMenuChild;

  /// Functional callback that is triggered when
  /// this [PieMenu] is opened and closed.
  final Function(bool menuVisible)? onToggle;

  @override
  State<PieMenu> createState() => _PieMenuState();
}

class _PieMenuState extends State<PieMenu> {
  late DisplayedCanvasState _canvasState;
  RenderBox? _renderBox;

  @override
  Widget build(BuildContext context) {
    try {
      _canvasState = InheritedCanvas.of(context)!.canvasKey.currentState!;

      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _renderBox = context.findRenderObject() as RenderBox;
          _canvasState.pointerDown(
            child: widget.visibleMenuChild ?? widget.child,
            renderBox: _renderBox!,
            offset: event.position,
            actions: widget.actions,
            theme: widget.theme,
            onMenuToggle: widget.onToggle,
          );
        },
        onPointerMove: (event) => _canvasState.pointerMove(event.position),
        onPointerUp: (event) => _canvasState.pointerUp(event.position),
        child: widget.child,
      );
    } catch (e) {
      return widget.child;
    }
  }
}
