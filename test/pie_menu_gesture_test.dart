import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  group('PieMenu gestures', () {
    testWidgets('normal tap calls onPressed exactly once', (tester) async {
      var pressCount = 0;

      await tester.pumpWidget(_testApp(onPressed: () => pressCount++));

      await tester.tap(_movieFinder);
      await tester.pumpAndSettle();

      expect(pressCount, 1);
    });

    testWidgets('ListView drag does not call onPressed', (tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        _testApp(onPressed: () => pressCount++, scrollable: true),
      );

      await tester.drag(_movieFinder, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(pressCount, 0);
    });

    testWidgets('long press opens menu without calling onPressed', (
      tester,
    ) async {
      var pressCount = 0;

      await tester.pumpWidget(
        _testApp(
          onPressed: () => pressCount++,
          theme: const PieTheme(
            childBounceEnabled: false,
            longPressDuration: Duration(milliseconds: 100),
          ),
          actions: [
            PieAction(
              tooltip: const Text('Favorite'),
              onSelect: () {},
              child: const Icon(Icons.star),
            ),
          ],
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);

      await tester.longPress(_movieFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(pressCount, 0);
    });

    testWidgets('tap accepted by Flutter slop calls onPressed', (tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        _testApp(
          onPressed: () => pressCount++,
          gestureSettings: const DeviceGestureSettings(touchSlop: 40),
        ),
      );

      final start = tester.getCenter(_movieFinder);
      final gesture = await tester.startGesture(start);

      await gesture.moveTo(start + const Offset(20, 0));
      await tester.pump();
      await gesture.moveTo(start);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(pressCount, 1);
    });

    testWidgets('menu opened and closed during press suppresses onPressed', (
      tester,
    ) async {
      var pressCount = 0;
      final controller = PieMenuController();

      await tester.pumpWidget(
        _testApp(
          onPressed: () => pressCount++,
          controller: controller,
          theme: const PieTheme(
            childBounceEnabled: false,
            longPressShowsMenu: false,
          ),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(_movieFinder));
      controller.openMenu();
      await tester.pumpAndSettle();
      controller.closeMenu(animate: false);
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(pressCount, 0);
    });

    testWidgets('new tap works after controller closes an idle menu', (
      tester,
    ) async {
      var pressCount = 0;
      final controller = PieMenuController();

      await tester.pumpWidget(
        _testApp(
          onPressed: () => pressCount++,
          controller: controller,
          theme: const PieTheme(
            childBounceEnabled: false,
            longPressShowsMenu: false,
          ),
        ),
      );

      controller.openMenu();
      await tester.pumpAndSettle();
      controller.closeMenu(animate: false);
      await tester.pumpAndSettle();
      await tester.tap(_movieFinder);
      await tester.pumpAndSettle();

      expect(pressCount, 1);
    });

    testWidgets('regular tap calls onPressed and opens menu', (tester) async {
      var pressCount = 0;

      await tester.pumpWidget(
        _testApp(
          onPressed: () => pressCount++,
          theme: const PieTheme(
            childBounceEnabled: false,
            regularPressShowsMenu: true,
          ),
          actions: [
            PieAction(
              tooltip: const Text('Favorite'),
              onSelect: () {},
              child: const Icon(Icons.star),
            ),
          ],
        ),
      );

      await tester.tap(_movieFinder);
      await tester.pumpAndSettle();

      expect(pressCount, 1);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}

final _movieFinder = find.descendant(
  of: find.byType(PieMenu),
  matching: find.text('Movie'),
);

Widget _testApp({
  required VoidCallback onPressed,
  PieTheme theme = const PieTheme(childBounceEnabled: false),
  List<PieAction> actions = const [],
  bool scrollable = false,
  DeviceGestureSettings? gestureSettings,
  PieMenuController? controller,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final menu = SizedBox(
          height: 120,
          child: Center(
            child: PieMenu(
              actions: actions,
              onPressed: onPressed,
              controller: controller,
              child: const Text('Movie'),
            ),
          ),
        );

        final body = scrollable
            ? ListView(children: [menu, const SizedBox(height: 1200)])
            : Center(child: menu);

        Widget canvas = PieCanvas(
          theme: theme,
          child: Scaffold(body: body),
        );

        if (gestureSettings != null) {
          canvas = MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(gestureSettings: gestureSettings),
            child: canvas,
          );
        }

        return canvas;
      },
    ),
  );
}
