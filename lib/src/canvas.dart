import 'package:flutter/material.dart';
import 'package:pie_menu/src/displayed_canvas.dart';
import 'package:pie_menu/src/menu.dart';
import 'package:pie_menu/src/theme.dart';

/// An overlay widget that displays the [PieMenu]s physically
/// and highlights the child widgets of the menus.
class PieCanvas extends StatefulWidget {
  const PieCanvas({
    Key? key,
    required this.child,
    this.theme = const PieTheme(),
    this.onMenuToggle,
  }) : super(key: key);

  /// Widget to display behind the canvas.
  final Widget child;

  /// The theme to use for any [PieMenu] that inherits this canvas,
  /// if not overridden by the menu itself.
  final PieTheme theme;

  /// Functional callback that is triggered when a [PieMenu] that
  /// inherits this canvas is opened and closed.
  ///
  /// If there is a [Scrollable] widget in the sub-hierarchy of the [child],
  /// this callback can be used to disable scrolling by rebuilding the widget
  /// and giving the scrollable a [NeverScrollableScrollPhysics] as physics
  /// if a [PieMenu] is visible on the screen.
  final Function(bool menuVisible)? onMenuToggle;

  @override
  State<PieCanvas> createState() => _PieCanvasState();
}

class _PieCanvasState extends State<PieCanvas> {
  final _canvasKey = GlobalKey<DisplayedCanvasState>();

  @override
  Widget build(BuildContext context) {
    return InheritedCanvas(
      canvasKey: _canvasKey,
      child: widget.child,
      theme: widget.theme,
      onMenuToggle: widget.onMenuToggle,
    );
  }
}
