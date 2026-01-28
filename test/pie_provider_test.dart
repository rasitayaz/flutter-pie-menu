import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pie_menu/src/pie_canvas_core.dart';
import 'package:pie_menu/src/pie_provider.dart';

void main() {
  group(PieProvider, () {
    testWidgets('provides PieNotifier to descendants', (tester) async {
      late PieNotifier notifier;

      await tester.pumpWidget(
        MaterialApp(
          home: PieCanvas(
            child: Builder(
              builder: (context) {
                notifier = PieNotifier.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(notifier, isNotNull);
      expect(notifier, isA<PieNotifier>());
    });

    testWidgets('throws exception if PieCanvas is missing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PieNotifier.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      final exception = tester.takeException();
      expect(exception, isInstanceOf<Exception>());
      expect(
        exception.toString(),
        contains('Could not find any PieCanvas'),
      );
    });

    testWidgets('updateShouldNotify returns true', (tester) async {
      final notifier = PieNotifier(
        canvasCoreKey: GlobalKey<PieCanvasCoreState>(),
      );

      final provider = PieProvider(
        notifier: notifier,
        builder: (context) => const SizedBox(),
      );

      expect(provider.updateShouldNotify(provider), isTrue);
    });
  });
}
