import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_theme.dart';

class PieState {
  const PieState({
    required this.active,
    required this.forceClose,
    required this.theme,
    required this.menuRenderBox,
    required this.menuKey,
  });

  final bool active;
  final bool forceClose;
  final PieTheme theme;
  final RenderBox? menuRenderBox;
  final Key? menuKey;
}

/// This widget provides a global [PieCanvasOverlayState] key
/// for the [PieMenu]s that inherit a [PieCanvas].
class PieProvider extends InheritedWidget {
  PieProvider({
    super.key,
    required this.canvasOverlayKey,
    required this.canvasTheme,
    required this.state,
    required this.emit,
    required Function(bool active)? onMenuToggle,
    required Widget child,
  }) : super(
          child: PieCanvasOverlay(
            key: canvasOverlayKey,
            theme: canvasTheme,
            onMenuToggle: onMenuToggle,
            child: child,
          ),
        );

  /// [PieMenu] can control the appearance of the menu
  /// displayed on the [PieCanvas] using this key.
  final GlobalKey<PieCanvasOverlayState> canvasOverlayKey;

  /// [PieMenu] can access the canvas theme using this property.
  final PieTheme canvasTheme;

  final PieState state;

  PieCanvasOverlayState get overlayState => canvasOverlayKey.currentState!;

  final void Function({
    bool? active,
    bool? forceClose,
    PieTheme? theme,
    RenderBox? menuRenderBox,
    Key? menuKey,
  }) emit;

  static PieProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PieProvider>();

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
  bool updateShouldNotify(PieProvider oldWidget) {
    return oldWidget.state.active != state.active;
  }
}
