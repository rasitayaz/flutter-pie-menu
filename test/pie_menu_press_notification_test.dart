import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  group(PieMenuPressNotification, () {
    testWidgets('notification bubbles up', (tester) async {
      bool notificationReceived = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationListener<PieMenuPressNotification>(
              onNotification: (notification) {
                notificationReceived = true;
                return true;
              },
              child: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      const PieMenuPressNotification().dispatch(context);
                    },
                    child: const Text('Tap Me'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(notificationReceived, isTrue);
    });
  });
}
