import 'package:flutter/widgets.dart';

abstract class PieMenuEvent {}

class PieMenuOpenEvent extends PieMenuEvent {
  PieMenuOpenEvent({
    required this.menuAlignment,
    required this.menuDisplacement,
  });

  final Alignment menuAlignment;
  final Offset? menuDisplacement;
}

class PieMenuCloseEvent extends PieMenuEvent {}

class PieMenuToggleEvent extends PieMenuEvent {
  PieMenuToggleEvent({
    required this.menuAlignment,
    required this.menuDisplacement,
  });

  final Alignment menuAlignment;
  final Offset? menuDisplacement;
}
