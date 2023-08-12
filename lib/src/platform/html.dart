// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'base.dart';

BasePlatform getPlatform() => _HtmlPlatform();

class _HtmlPlatform implements BasePlatform {
  @override
  dynamic listenContextMenu({required bool preventDefault}) {
    return document.onContextMenu.listen((event) {
      if (preventDefault) {
        event.preventDefault();
      }
    });
  }
}
