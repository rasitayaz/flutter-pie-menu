import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_provider.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// An ancestor widget that is required for any [PieMenu] to function.
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
  final Function(bool active)? onMenuToggle;

  @override
  State<PieCanvas> createState() => _PieCanvasState();
}

class _PieCanvasState extends State<PieCanvas> {
  final _canvasOverlayKey = GlobalKey<PieCanvasOverlayState>();

  @override
  Widget build(BuildContext context) {
    return PieProvider(
      state: PieState(
        canvasOverlayKey: _canvasOverlayKey,
        theme: widget.theme,
        active: false,
        forceClose: false,
        menuRenderBox: null,
        menuKey: null,
      ),
      child: PieCanvasOverlay(
        key: _canvasOverlayKey,
        theme: widget.theme,
        onMenuToggle: widget.onMenuToggle,
        child: widget.child,
      ),
    );
  }
}
