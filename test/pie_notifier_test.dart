import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_provider.dart';

void main() {
  group(PieNotifier, () {
    testWidgets('initial state is correct', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final key = GlobalKey<PieCanvasCoreState>();
                final notifier = PieNotifier(canvasCoreKey: key);

                expect(notifier.state.menuKey, isNull);
                expect(notifier.state.menuOpen, isFalse);
                expect(notifier.state.hoveredAction, isNull);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('update modifies state and notifies listeners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final key = GlobalKey<PieCanvasCoreState>();
                final notifier = PieNotifier(canvasCoreKey: key);

                bool listenerCalled = false;
                notifier.addListener(() {
                  listenerCalled = true;
                });

                final menuKey = UniqueKey();
                notifier.update(
                  menuKey: menuKey,
                  menuOpen: true,
                  hoveredAction: 1,
                );

                expect(notifier.state.menuKey, menuKey);
                expect(notifier.state.menuOpen, isTrue);
                expect(notifier.state.hoveredAction, 1);
                expect(listenerCalled, isTrue);

                notifier.update(
                  clearMenuKey: true,
                  clearHoveredAction: true,
                );

                expect(notifier.state.menuKey, isNull);
                expect(notifier.state.hoveredAction, isNull);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}
