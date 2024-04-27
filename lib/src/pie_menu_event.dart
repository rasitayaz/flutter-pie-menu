import 'package:flutter/widgets.dart';

abstract class PieMenuEvent {
  T map<T>({
    required T Function(PieMenuOpenEvent) open,
    required T Function(PieMenuCloseEvent) close,
  }) {
    final event = this;

    if (event is PieMenuOpenEvent) {
      return open(event);
    } else if (event is PieMenuCloseEvent) {
      return close(event);
    }

    throw Exception('Unhandled subtype of PieMenuEvent');
  }
}

class PieMenuOpenEvent extends PieMenuEvent {
  PieMenuOpenEvent({
    required this.menuAlignment,
    required this.menuDisplacement,
  });

  final Alignment menuAlignment;
  final Offset? menuDisplacement;
}

class PieMenuCloseEvent extends PieMenuEvent {}
