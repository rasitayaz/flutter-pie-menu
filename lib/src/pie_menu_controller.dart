import 'package:flutter/foundation.dart';

/// Controller for programmatically emitting [PieMenu] events.
class PieMenuController extends ChangeNotifier {
  void emitTapEvent() {
    super.notifyListeners();
  }
}
