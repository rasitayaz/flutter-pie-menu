import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_menu_event.dart';

void main() {
  group(PieMenuController, () {
    test('initial value is correct', () {
      final controller = PieMenuController();
      expect(controller.value, isA<PieMenuEvent>());
    });

    test('openMenu emits PieMenuOpenEvent', () {
      final controller = PieMenuController();
      controller.openMenu();
      expect(controller.value, isA<PieMenuOpenEvent>());
    });

    test('closeMenu emits PieMenuCloseEvent', () {
      final controller = PieMenuController();
      controller.closeMenu();
      expect(controller.value, isA<PieMenuCloseEvent>());
    });

    test('toggleMenu emits PieMenuToggleEvent', () {
      final controller = PieMenuController();
      controller.toggleMenu();
      expect(controller.value, isA<PieMenuToggleEvent>());
    });

    test('openMenu with parameters emits correct event data', () {
      final controller = PieMenuController();
      const alignment = Alignment.center;
      const displacement = Offset(10, 10);

      controller.openMenu(
          menuAlignment: alignment, menuDisplacement: displacement);

      final event = controller.value as PieMenuOpenEvent;
      expect(event.menuAlignment, alignment);
      expect(event.menuDisplacement, displacement);
    });
  });
}
