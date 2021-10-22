import 'package:flutter/material.dart';
import 'package:pie_menu/src/action.dart';
import 'package:pie_menu/src/button.dart';
import 'package:pie_menu/src/canvas.dart';
import 'package:pie_menu/src/displayed_canvas.dart';
import 'package:pie_menu/src/theme.dart';

/// Widget to display menu with multiple [PieAction]s for its child.
class PieMenu extends StatefulWidget {
  const PieMenu({
    Key? key,
    this.theme,
    required this.child,
    this.actions = const [],
  }) : super(key: key);

  /// Theme to use for this menu, overrides [PieCanvas] theme.
  final PieTheme? theme;

  /// Actions to display as [PieButton]s on the [PieCanvas].
  final List<PieAction> actions;

  /// Child widget to recognize pointer events.
  final Widget child;

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
    } catch (e) {
      throw Exception(
        'Use [PieMenu] widget only in the sub-hierarchy of a'
        ' [PieCanvas] widget.',
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _renderBox = context.findRenderObject() as RenderBox;

        _canvasState.pointerDown(
          child: widget.child,
          renderBox: _renderBox!,
          pressedOffset: event.position,
          actions: widget.actions,
          theme: widget.theme,
        );
      },
      onPointerMove: (event) {
        _canvasState.pointerMove(event.position);
      },
      onPointerUp: (event) {
        _canvasState.pointerUp();
      },
      child: widget.child,
    );
  }
}
