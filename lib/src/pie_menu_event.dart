import 'package:flutter/widgets.dart';

abstract class PieMenuEvent {
  T map<T>({
    required T Function(PieMenuOpenEvent) open,
    required T Function(PieMenuCloseEvent) close,
  }) {
    if (this is PieMenuOpenEvent) {
      return open(this as PieMenuOpenEvent);
    } else if (this is PieMenuCloseEvent) {
      return close(this as PieMenuCloseEvent);
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
  final Offset menuDisplacement;
}

class PieMenuCloseEvent extends PieMenuEvent {}
