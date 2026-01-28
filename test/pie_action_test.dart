import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pie_menu/pie_menu.dart';

void main() {
  group(PieAction, () {
    test('properties are set correctly', () {
      final action = PieAction(
        tooltip: const Text('Tooltip'),
        onSelect: () {},
        child: const Icon(Icons.add),
      );

      expect(action.tooltip, isA<Text>());
      expect(action.child, isA<Icon>());
      expect(action.onSelect, isNotNull);
    });

    test('builder constructor works correctly', () {
      final action = PieAction.builder(
        tooltip: const Text('Tooltip'),
        onSelect: () {},
        builder: (hovered) {
          return Text(hovered ? 'Hovered' : 'Normal');
        },
      );

      expect(action.builder, isNotNull);

      final normalWidget = action.builder!(false);
      expect((normalWidget as Text).data, 'Normal');

      final hoveredWidget = action.builder!(true);
      expect((hoveredWidget as Text).data, 'Hovered');
    });
  });
}
