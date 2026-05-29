import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_button.dart';

void main() {
  group(PieButton, () {
    testWidgets('renders correctly', (tester) async {
      final action = PieAction(
        tooltip: const Text('Tooltip'),
        onSelect: () {},
        child: const Icon(Icons.add),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: PieButton(
                theme: const PieTheme(),
                action: action,
                angle: 0,
                hovered: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders hovered state correctly', (tester) async {
      final action = PieAction(
        tooltip: const Text('Tooltip'),
        onSelect: () {},
        child: const Icon(Icons.add),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Scaffold(
              body: PieButton(
                theme: const PieTheme(
                  buttonThemeHovered: PieButtonTheme(
                    backgroundColor: Colors.red,
                    iconColor: Colors.yellow,
                  ),
                ),
                action: action,
                angle: 0,
                hovered: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PieButton),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('overrides color and size from parent icon theme and respects '
        'other properties', (tester) async {
      final action = PieAction(
        tooltip: const Text('Tooltip'),
        onSelect: () {},
        child: const Icon(Icons.add),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: IconTheme(
            data: const IconThemeData(
              color: Colors.red,
              size: 36.0,
              weight: 700,
            ),
            child: PieCanvas(
              child: Scaffold(
                body: PieButton(
                  theme: const PieTheme(
                    iconSize: 24.0,
                    buttonTheme: PieButtonTheme(
                      backgroundColor: Colors.blue,
                      iconColor: Colors.green,
                    ),
                  ),
                  action: action,
                  angle: 0,
                  hovered: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);

      final iconThemeData = IconTheme.of(
        tester.element(find.byIcon(Icons.add)),
      );
      expect(iconThemeData.color, Colors.green);
      expect(iconThemeData.size, 24.0);
      expect(iconThemeData.weight, 700);
    });
  });
}
