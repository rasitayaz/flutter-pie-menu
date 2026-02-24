import 'package:flutter/widgets.dart';

abstract class PieMenuEvent {}

class PieMenuIdleEvent extends PieMenuEvent {}

class PieMenuOpenEvent extends PieMenuEvent {
  PieMenuOpenEvent({
    required this.menuAlignment,
    required this.menuDisplacement,
  });

  final Alignment menuAlignment;
  final Offset? menuDisplacement;
}

class PieMenuCloseEvent extends PieMenuEvent {
  PieMenuCloseEvent({this.animate = true});

  final bool animate;
}

class PieMenuToggleEvent extends PieMenuEvent {
  PieMenuToggleEvent({
    required this.menuAlignment,
    required this.menuDisplacement,
  });

  final Alignment menuAlignment;
  final Offset? menuDisplacement;
}
