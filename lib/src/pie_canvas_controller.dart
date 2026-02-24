import 'package:flutter/widgets.dart';
import 'package:pie_menu/src/pie_canvas.dart';
import 'package:pie_menu/src/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_event.dart';

/// Controller for the [PieCanvas].
class PieCanvasController extends ValueNotifier<PieMenuEvent> {
  PieCanvasController() : super(PieMenuIdleEvent());

  /// Closes any open [PieMenu] on the canvas.
  ///
  /// Set [animate] to false to force close the menu without animation.
  void closeMenu({bool animate = true}) {
    value = PieMenuCloseEvent(animate: animate);
  }
}
