import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_core.dart';
import 'package:pie_menu/src/pie_theme.dart';

/// Contains variables shared between [PieCanvasCore] and [PieMenuCore].
class PieState {
  PieState({
    required this.menuKey,
    required this.active,
    required this.hoveredAction,
  });

  /// Unique key of the currently active menu.
  final Key? menuKey;

  /// Whether any menu is currently active.
  final bool active;

  /// Whether any menu action is currently hovered.
  final int? hoveredAction;
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
  var state = PieState(
    menuKey: null,
    active: false,
    hoveredAction: null,
  );

  /// Current state of the [PieCanvasCore].
  PieCanvasCoreState get canvas => _canvasCoreKey.currentState!;

  /// Updates the shared state and notifies listeners.
  void update({
    Key? menuKey,
    bool clearMenuKey = false,
    bool? active,
    int? hoveredAction,
    bool clearHoveredAction = false,
  }) {
    state = PieState(
      menuKey: clearMenuKey ? null : menuKey ?? state.menuKey,
      active: active ?? state.active,
      hoveredAction:
          clearHoveredAction ? null : hoveredAction ?? state.hoveredAction,
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
        'Ensure that every PieMenu has a PieCanvas ancestor.\n\n'
        'For more information, see the pie_menu documentation.\n'
        'https://pub.dev/packages/pie_menu',
      );
    }

    return provider.notifier;
  }
}
