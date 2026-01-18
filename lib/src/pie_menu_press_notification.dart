import 'package:flutter/widgets.dart';
import 'package:pie_menu/src/pie_menu.dart';

/// Notification triggered when the menu is pressed.
///
/// This notification is used to notify the parent widget of the menu press.
/// It can be useful when using nested [PieMenu] widgets.
///
/// Dispatching this notification from a child widget of [PieMenu] will
/// prevent the [PieMenu] from handling the press event (e.g. bounce animation).
class PieMenuPressNotification extends Notification {
  const PieMenuPressNotification();
}
