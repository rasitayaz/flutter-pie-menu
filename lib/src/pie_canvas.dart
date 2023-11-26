import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_core.dart';
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

  /// The theme to use for any descendant [PieMenu]
  /// if not overridden by the menu itself.
  final PieTheme theme;

  /// Functional callback triggered when
  /// any descendant [PieMenu] becomes active or inactive.
  final Function(bool active)? onMenuToggle;

  @override
  State<PieCanvas> createState() => _PieCanvasState();
}

class _PieCanvasState extends State<PieCanvas> {
  /// Key for the [PieCanvasCore] widget, [PieMenuCore] needs this
  /// to attach itself to the canvas.
  final _canvasCoreKey = GlobalKey<PieCanvasCoreState>();

  /// Notifies both [PieCanvasCore] and [PieMenuCore] for shared state changes.
  late final _notifier = PieNotifier(
    canvasCoreKey: _canvasCoreKey,
    canvasTheme: widget.theme,
  );

  @override
  Widget build(BuildContext context) {
    return PieProvider(
      notifier: _notifier,
      builder: (context) {
        return PieCanvasCore(
          key: _canvasCoreKey,
          onMenuToggle: widget.onMenuToggle,
          child: widget.child,
        );
      },
    );
  }
}
