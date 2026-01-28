import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_provider.dart';

void main() {
  group(PieCanvasCore, () {
    testWidgets('toggles menu based on right click setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: const PieTheme(
              rightClickShowsMenu: true,
              leftClickShowsMenu: false,
            ),
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
                  child: const Text('Right Click Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify menu not visible.
      expect(find.byIcon(Icons.add), findsNothing);

      // Left click should not open menu.
      final center = tester.getCenter(find.text('Right Click Me'));
      final leftClickGesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
        buttons: kPrimaryMouseButton,
      );
      await leftClickGesture.addPointer(location: center);
      await leftClickGesture.down(center);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsNothing);
      await leftClickGesture.up();
      await leftClickGesture.removePointer();

      // Right click should open menu.
      final rightClickGesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 2,
        buttons: kSecondaryMouseButton,
      );
      await rightClickGesture.addPointer(location: center);
      await rightClickGesture.down(center);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
      await rightClickGesture.up();
      await rightClickGesture.removePointer();
    });

    testWidgets('updates custom theme correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  theme: const PieTheme(overlayColor: Colors.red),
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

      await tester.longPress(find.text('Open Me'));
      await tester.pumpAndSettle();

      final coloredBox = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(PieCanvasCore),
              matching: find.byType(ColoredBox),
            )
            .first,
      );

      expect(coloredBox.color, Colors.red);
    });

    testWidgets('renders OverlayPainter when style is around', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  theme: const PieTheme(
                    overlayStyle: PieOverlayStyle.around,
                    overlayColor: Colors.blue,
                  ),
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

      await tester.longPress(find.text('Open Me'));
      await tester.pumpAndSettle();

      final customPaintFinder = find.descendant(
        of: find.byType(PieCanvasCore),
        matching: find.byWidgetPredicate((widget) {
          return widget is CustomPaint && widget.painter is OverlayPainter;
        }),
      );

      expect(customPaintFinder, findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      final painter = customPaint.painter as OverlayPainter;
      expect(painter.color, Colors.blue);
    });

    testWidgets('closeMenu checks for correct menu key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
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

      // Open the menu.
      await tester.longPress(find.text('Open Me'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);

      final canvasCoreState = tester.state<PieCanvasCoreState>(
        find.byType(PieCanvasCore),
      );
      final notifier = PieNotifier.of(canvasCoreState.context);
      final validKey = notifier.state.menuKey;
      expect(validKey, isNotNull);

      // Verify menu is open and visible.
      expect(notifier.state.menuOpen, isTrue);

      // Try closing with valid key.
      canvasCoreState.closeMenu(validKey!);
      await tester.pumpAndSettle();

      expect(notifier.state.menuOpen, isFalse);

      // Re-open and try closing with invalid key.
      final triggerFinder = find.descendant(
        of: find.byType(PieMenu),
        matching: find.text('Open Me'),
      );
      await tester.longPress(triggerFinder);
      await tester.pumpAndSettle();
      expect(notifier.state.menuOpen, isTrue);

      canvasCoreState.closeMenu(UniqueKey());
      await tester.pumpAndSettle();
      expect(notifier.state.menuOpen, isTrue); // Should still be open.
    });
  });
}
