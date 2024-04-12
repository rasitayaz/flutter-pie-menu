import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Controller for programmatically emitting [PieMenu] events.
class PieMenuController extends ValueNotifier<PieMenuEvent> {
  PieMenuController() : super(PieMenuEvent.closeMenu);

  void openMenu() {
    value = PieMenuEvent.openMenu;
  }

  void closeMenu() {
    value = PieMenuEvent.closeMenu;
  }
}

enum PieMenuEvent { openMenu, closeMenu }
