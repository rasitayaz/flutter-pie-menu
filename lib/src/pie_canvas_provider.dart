import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// This widget provides a global [PieCanvasOverlayState] key
/// for the [PieMenu]s that inherit a [PieCanvas].
class PieCanvasProvider extends InheritedWidget {
  PieCanvasProvider({
    super.key,
    required this.theme,
    Function(bool active)? onMenuToggle,
    required this.canvasKey,
    required Widget child,
    bool isHighlightedChild = true,
  }) : super(
          child: PieCanvasOverlay(
            key: canvasKey,
            theme: theme,
            onMenuToggle: onMenuToggle,
            isHighlightedChild: isHighlightedChild,
            child: child,
          ),
        );

  /// [PieMenu] can control the appearance of the menu
  /// displayed on the [PieCanvas] using this key.
  final GlobalKey<PieCanvasOverlayState> canvasKey;

  /// [PieMenu] can access the canvas theme using this property.
  final PieTheme theme;

  static PieCanvasProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PieCanvasProvider>();
    if (provider == null) {
      throw Exception(
        'Could not find any PieCanvas.\n'
        'Please make sure there is a PieCanvas that inherits PieMenu.\n\n'
        'For more information, see the pie_menu documentation.\n'
        'https://pub.dev/packages/pie_menu',
      );
    }
    return provider;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
