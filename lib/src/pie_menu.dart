import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_action.dart';
import 'package:pie_menu/src/pie_button.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_canvas_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Widget that displays [PieAction]s as circular buttons for its child.
class PieMenu extends StatefulWidget {
  const PieMenu({
    super.key,
    this.theme,
    this.actions = const [],
    this.onToggle,
    this.visibleMenuChild,
    required this.child,
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
  State<PieMenu> createState() => PieMenuState();
}

class PieMenuState extends State<PieMenu> {
  bool _childVisible = true;

  void setVisibility(bool visible) {
    if (visible != _childVisible) {
      setState(() {
        _childVisible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final canvas = PieCanvasProvider.of(context)?.canvasKey.currentState;
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (canvas == null) {
            throw Exception(
              'Could not find any PieCanvas.\n'
              'Please make sure there is a PieCanvas at the parent widget hierarchy of PieMenu.\n\n'
              'For more information, see the pie_menu documentation.\n'
              'https://pub.dev/packages/pie_menu',
            );
          }
          canvas.pointerDown(
            state: this,
            child: widget.visibleMenuChild ?? widget.child,
            renderBox: context.findRenderObject() as RenderBox,
            offset: event.position,
            actions: widget.actions,
            theme: widget.theme,
            onMenuToggle: widget.onToggle,
          );
        },
        onPointerMove: (event) => canvas?.pointerMove(event.position),
        onPointerUp: (event) => canvas?.pointerUp(event.position),
        child: Opacity(
          opacity: _childVisible ? 1 : 0,
          child: widget.child,
        ),
      );
    } catch (e) {
      return widget.child;
    }
  }
}
