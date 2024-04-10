import 'package:flutter/foundation.dart';

/// Controller for programmatically emitting [PieMenu] events.
class PieMenuTapController extends ChangeNotifier {
  void emitTapEvent() {
    super.notifyListeners();
  }
}
