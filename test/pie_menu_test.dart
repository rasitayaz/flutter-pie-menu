import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_button.dart';

void main() {
  group(PieMenu, () {
    testWidgets('renders PieCanvas and PieMenu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {},
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Tap Me'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      expect(find.byType(PieMenu), findsOneWidget);
      expect(find.byType(PieCanvas), findsOneWidget);
    });

    testWidgets('long press opens the menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: const PieTheme(
              longPressDuration: Duration(milliseconds: 100),
            ),
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {},
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Long Press Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify menu is not visible initially.
      expect(find.byIcon(Icons.ac_unit), findsNothing);

      // Long press.
      await tester.longPress(find.text('Long Press Me'));
      await tester.pumpAndSettle();

      // Verify menu is visible.
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('selecting an action triggers onSelect', (tester) async {
      bool actionSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: const PieTheme(
              longPressDuration: Duration(milliseconds: 100),
            ),
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {
                        actionSelected = true;
                      },
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Long Press Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open menu.
      await tester.longPress(find.text('Long Press Me'));
      await tester.pumpAndSettle();

      // Drag to action.
      final actionFinder = find.byIcon(Icons.ac_unit);

      // Simulate a drag from the center to the action.
      // The menu is likely centered on the Long Press Me text.
      final menuTextFinder = find.text('Long Press Me');
      final menuCenter = tester.getCenter(menuTextFinder.first);
      final actionCenter = tester.getCenter(actionFinder);

      await tester.dragFrom(menuCenter, actionCenter - menuCenter);
      await tester.pumpAndSettle();

      await tester.tapAt(actionCenter);
      await tester.pumpAndSettle();

      expect(actionSelected, isTrue);
    });

    testWidgets('controller opens the menu', (tester) async {
      final controller = PieMenuController();

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  controller: controller,
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {},
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Controller Me'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.ac_unit), findsNothing);

      controller.openMenu();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('right click opens menu when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: const PieTheme(
              rightClickShowsMenu: true,
            ),
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {},
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Right Click Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify menu is hidden.
      expect(find.byIcon(Icons.ac_unit), findsNothing);

      // Right click.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Right Click Me')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify menu is visible.
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('hovering over action updates state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            theme: const PieTheme(
              buttonTheme: PieButtonTheme(
                backgroundColor: Colors.blue,
                iconColor: Colors.white,
              ),
              buttonThemeHovered: PieButtonTheme(
                backgroundColor: Colors.red,
                iconColor: Colors.white,
              ),
            ),
            child: Scaffold(
              body: Center(
                child: PieMenu(
                  actions: [
                    PieAction(
                      tooltip: const Text('Action 1'),
                      onSelect: () {},
                      child: const Icon(Icons.ac_unit),
                    ),
                  ],
                  child: const Text('Hover Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open menu.
      await tester.longPress(find.text('Hover Me'));
      await tester.pumpAndSettle();

      // Find the action button.
      final actionFinder = find.byIcon(Icons.ac_unit);
      final actionCenter = tester.getCenter(actionFinder);

      // Verify initial scale (not hovered).
      // PieButton -> OverflowBox -> AnimatedScale
      final scaleFinder = find.descendant(
        of: find.byType(PieButton),
        matching: find.byType(AnimatedScale),
      );
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1.0);

      // Hover over the action.
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(actionCenter);
      await tester.pumpAndSettle();

      // Verify scale updated (hovered).
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1.2);
    });
  });
}
