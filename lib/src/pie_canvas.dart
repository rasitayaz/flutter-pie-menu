import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// An overlay widget that displays the [PieMenu]s physically
/// and highlights the child widgets of the menus.
class PieCanvas extends StatefulWidget {
  const PieCanvas({
    super.key,
    this.theme = const PieTheme(),
    this.onMenuToggle,
    required this.child,
  });

  /// Widget to display behind the canvas.
  final Widget child;

  /// The theme to use for any [PieMenu] that inherits this canvas,
  /// if not overridden by the menu itself.
  final PieTheme theme;

  /// Functional callback that is triggered when a [PieMenu] that
  /// inherits this canvas is opened and closed.
  ///
  /// If there is a [Scrollable] widget in the sub-hierarchy of [child],
  /// this callback can be used to disable scrolling by rebuilding the widget
  /// and giving the scrollable a [NeverScrollableScrollPhysics]
  /// when a [PieMenu] is active.
  final Function(bool active)? onMenuToggle;

  @override
  State<PieCanvas> createState() => _PieCanvasState();
}

class _PieCanvasState extends State<PieCanvas> {
  final _canvasOverlayKey = GlobalKey<PieCanvasOverlayState>();

  late var _state = PieState(
    active: false,
    forceClose: false,
    theme: widget.theme,
    menuRenderBox: null,
    menuKey: null,
  );

  void _emit({
    bool? active,
    bool? forceClose,
    PieTheme? theme,
    RenderBox? menuRenderBox,
    Key? menuKey,
  }) {
    setState(() {
      _state = PieState(
        active: active ?? _state.active,
        forceClose: forceClose ?? false,
        theme: theme ?? _state.theme,
        menuRenderBox: menuRenderBox ?? _state.menuRenderBox,
        menuKey: menuKey ?? _state.menuKey,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PieProvider(
      canvasOverlayKey: _canvasOverlayKey,
      canvasTheme: widget.theme,
      state: _state,
      emit: _emit,
      onMenuToggle: widget.onMenuToggle,
      child: widget.child,
    );
  }
}
