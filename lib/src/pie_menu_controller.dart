import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_menu/src/pie_menu_event.dart';

/// Controller for programmatically emitting [PieMenu] events.
class PieMenuController extends ValueNotifier<PieMenuEvent> {
  PieMenuController() : super(PieMenuCloseEvent());

  void openMenu({
    Alignment? menuAlignment,
    Offset? menuDisplacement,
  }) {
    value = PieMenuOpenEvent(
      menuAlignment: menuAlignment,
      menuDisplacement: menuDisplacement,
    );
  }

  void closeMenu() {
    value = PieMenuCloseEvent();
  }
}
