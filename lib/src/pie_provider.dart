import 'package:flutter/material.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_theme.dart';

class PieProvider extends InheritedWidget {
  PieProvider({
    super.key,
    required this.state,
    required Widget Function(PieState state) builder,
  }) : super(
          child: Builder(
            builder: (context) {
              return ListenableBuilder(
                listenable: PieState.of(context),
                builder: (context, child) => builder(PieState.of(context)),
              );
            },
          ),
        );

  final PieState state;

  @override
  bool updateShouldNotify(PieProvider oldWidget) => true;
}

class PieState extends ChangeNotifier {
  PieState({
    required GlobalKey<PieCanvasCoreState> canvasCoreKey,
    required this.theme,
    required this.active,
    required this.forceClose,
    required this.menuRenderBox,
    required this.menuKey,
  })  : canvasTheme = theme,
        _canvasCoreKey = canvasCoreKey;

  final GlobalKey<PieCanvasCoreState> _canvasCoreKey;
  final PieTheme canvasTheme;

  bool active;
  bool forceClose;
  PieTheme theme;
  RenderBox? menuRenderBox;
  Key? menuKey;

  PieCanvasCoreState get core => _canvasCoreKey.currentState!;

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
