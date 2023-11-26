import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_theme.dart';

class PieState {
  PieState({
    required this.active,
    required this.theme,
    required this.menuRenderBox,
    required this.menuKey,
  });

  final bool active;
  final PieTheme theme;
  final RenderBox? menuRenderBox;
  final Key? menuKey;
}

class PieProvider extends InheritedWidget {
  PieProvider({
    super.key,
    required this.notifier,
    required Widget Function(BuildContext context) builder,
  }) : super(
          child: Builder(
            builder: (context) {
              return ListenableBuilder(
                listenable: notifier,
                builder: (context, child) => builder(context),
              );
            },
          ),
        );

  final PieNotifier notifier;

  @override
  bool updateShouldNotify(PieProvider oldWidget) => true;
}

class PieNotifier extends ChangeNotifier {
  PieNotifier({
    required GlobalKey<PieCanvasCoreState> canvasCoreKey,
    required this.canvasTheme,
  }) : _canvasCoreKey = canvasCoreKey;

  final GlobalKey<PieCanvasCoreState> _canvasCoreKey;
  final PieTheme canvasTheme;

  late var state = PieState(
    theme: canvasTheme,
    active: false,
    menuRenderBox: null,
    menuKey: null,
  );

  PieCanvasCoreState get core => _canvasCoreKey.currentState!;

  void update({
    bool shouldNotify = true,
    bool? active,
    PieTheme? theme,
    RenderBox? menuRenderBox,
    Key? menuKey,
  }) {
    state = PieState(
      active: active ?? state.active,
      theme: theme ?? state.theme,
      menuRenderBox: menuRenderBox ?? state.menuRenderBox,
      menuKey: menuKey ?? state.menuKey,
    );

    if (shouldNotify) notifyListeners();
  }

  static PieNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PieProvider>();

    if (provider == null) {
      throw Exception(
        'Could not find any PieCanvas.\n'
        'Please make sure there is a PieCanvas that inherits PieMenu.\n\n'
        'For more information, see the pie_menu documentation.\n'
        'https://pub.dev/packages/pie_menu',
      );
    }

    return provider.notifier;
  }
}
