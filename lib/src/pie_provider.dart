import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_overlay.dart';
import 'package:pie_menu/src/pie_theme.dart';

class PieProvider extends InheritedWidget {
  const PieProvider({
    super.key,
    required this.state,
    required super.child,
  });

  final PieState state;

  @override
  bool updateShouldNotify(PieProvider oldWidget) {
    return true;
  }
}

class PieState extends ChangeNotifier {
  PieState({
    required GlobalKey<PieCanvasOverlayState> canvasOverlayKey,
    required this.theme,
    required this.active,
    required this.forceClose,
    required this.menuRenderBox,
    required this.menuKey,
  })  : canvasTheme = theme,
        _canvasOverlayKey = canvasOverlayKey;

  final GlobalKey<PieCanvasOverlayState> _canvasOverlayKey;
  final PieTheme canvasTheme;

  bool active;
  bool forceClose;
  PieTheme theme;
  RenderBox? menuRenderBox;
  Key? menuKey;

  PieCanvasOverlayState get overlayState => _canvasOverlayKey.currentState!;

  void update({
    bool shouldNotify = true,
    bool? active,
    bool? forceClose,
    PieTheme? theme,
    RenderBox? menuRenderBox,
    Key? menuKey,
  }) {
    this.active = active ?? this.active;
    this.forceClose = forceClose ?? false;
    this.theme = theme ?? this.theme;
    this.menuRenderBox = menuRenderBox ?? this.menuRenderBox;
    this.menuKey = menuKey ?? this.menuKey;

    if (shouldNotify) notifyListeners();
  }

  static PieState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PieProvider>();

    if (provider == null) {
      throw Exception(
        'Could not find any PieCanvas.\n'
        'Please make sure there is a PieCanvas that inherits PieMenu.\n\n'
        'For more information, see the pie_menu documentation.\n'
        'https://pub.dev/packages/pie_menu',
      );
    }

    return provider.state;
  }
}
