import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_provider.dart';

void main() {
  group(PieCanvas, () {
    testWidgets('builds PieProvider and PieCanvasCore', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: const Text('Canvas Child'),
          ),
        ),
      );

      expect(find.text('Canvas Child'), findsOneWidget);
      expect(find.byType(PieProvider), findsOneWidget);
      expect(find.byType(PieCanvasCore), findsOneWidget);
    });

    testWidgets('onMenuToggle is called when menu toggles', (tester) async {
      bool menuOpen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            onMenuToggle: (isOpen) {
              menuOpen = isOpen;
            },
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action'),
                      onSelect: () {},
                      child: const Icon(Icons.add),
                    ),
                  ],
                  child: const Text('Open Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open menu
      await tester.longPress(find.text('Open Me'));
      await tester.pumpAndSettle();
      expect(menuOpen, isTrue);

      // Close menu by tapping outside (center of canvas roughly, avoiding the menu items)
      // Actually, tapping the canvas/child should close it if not on an action
      // The menu is centered.
      // Let's tap top left.
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();
      expect(menuOpen, isFalse);
    });
  });
}
