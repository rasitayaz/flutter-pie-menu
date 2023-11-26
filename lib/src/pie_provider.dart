import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_core.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Contains variables shared between [PieCanvasCore] and [PieMenuCore].
class PieState {
  PieState({
    required this.active,
    required this.theme,
    required this.menuRenderBox,
    required this.menuKey,
  });

  /// Whether any menu is currently active.
  final bool active;

  /// Current theme applied to the canvas.
  final PieTheme theme;

  /// RenderBox of the currently active menu.
  final RenderBox? menuRenderBox;

  /// Unique key of the currently active menu.
  final Key? menuKey;
}

/// Provides [PieState] to [PieCanvasCore] and [PieMenuCore].
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

  /// Notifier that controls the shared state.
  final PieNotifier notifier;

  @override
  bool updateShouldNotify(PieProvider oldWidget) => true;
}

/// Controls the shared state between [PieCanvasCore] and [PieMenuCore].
///
/// Can be accessed by canvas and menu using [PieNotifier.of].
class PieNotifier extends ChangeNotifier {
  PieNotifier({
    required GlobalKey<PieCanvasCoreState> canvasCoreKey,
    required this.canvasTheme,
  }) : _canvasCoreKey = canvasCoreKey;

  /// Key for the [PieCanvasCore] widget, [PieMenuCore] needs this
  /// to attach itself to the canvas.
  final GlobalKey<PieCanvasCoreState> _canvasCoreKey;

  /// Theme to use for any descendant [PieMenu]
  /// if not overridden by the menu itself.
  final PieTheme canvasTheme;

  /// Current state shared between [PieCanvasCore] and [PieMenuCore].
  late var state = PieState(
    theme: canvasTheme,
    active: false,
    menuRenderBox: null,
    menuKey: null,
  );

  /// Current state of the [PieCanvasCore].
  PieCanvasCoreState get core => _canvasCoreKey.currentState!;

  /// Updates the shared state and notifies listeners.
  void update({
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

    notifyListeners();
  }

  /// Returns the closest [PieNotifier] instance
  /// that encloses the given context.
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
