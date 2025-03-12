import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_menu_core.dart';

/// Contains variables shared between [PieCanvasCore] and [PieMenuCore].
class PieState {
  PieState({
    required this.menuKey,
    required this.menuOpen,
    required this.hoveredAction,
    this.hoveredSubmenuAction,
  });

  /// Unique key of the currently open menu.
  final Key? menuKey;

  /// Whether any menu is currently open.
  final bool menuOpen;

  /// Whether any menu action is currently hovered.
  final int? hoveredAction;

  /// Whether any submenu action is currently hovered.
  final int? hoveredSubmenuAction;
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
  }) : _canvasCoreKey = canvasCoreKey;

  /// Key for the [PieCanvasCore] widget, [PieMenuCore] needs this
  /// to attach itself to the canvas.
  final GlobalKey<PieCanvasCoreState> _canvasCoreKey;

  /// Current state shared between [PieCanvasCore] and [PieMenuCore].
  var state = PieState(
    menuKey: null,
    menuOpen: false,
    hoveredAction: null,
  );

  /// Current state of the [PieCanvasCore].
  PieCanvasCoreState get canvas => _canvasCoreKey.currentState!;

  /// Updates the shared state and notifies listeners.
  void update({
    Key? menuKey,
    bool clearMenuKey = false,
    bool? menuOpen,
    int? hoveredAction,
    int? hoveredSubmenuAction,
    bool clearHoveredAction = false,
    bool clearHoveredSubmenuAction = false,
  }) {
    state = PieState(
      menuKey: clearMenuKey ? null : menuKey ?? state.menuKey,
      menuOpen: menuOpen ?? state.menuOpen,
      hoveredAction:
          clearHoveredAction ? null : hoveredAction ?? state.hoveredAction,
      hoveredSubmenuAction: clearHoveredSubmenuAction
          ? null
          : hoveredSubmenuAction ?? state.hoveredSubmenuAction,
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
