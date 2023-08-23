// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'base.dart';

BasePlatform getPlatform() => _HtmlPlatform();

/// HTML implementation of [BasePlatform].
class _HtmlPlatform implements BasePlatform {
  @override
  dynamic listenContextMenu({required bool shouldPreventDefault}) {
    return document.onContextMenu.listen((event) {
      if (shouldPreventDefault) {
        event.preventDefault();
      }
    });
  }
}
