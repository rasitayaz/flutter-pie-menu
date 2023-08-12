import 'platform.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.html) 'html.dart';

abstract class BasePlatform {
  factory BasePlatform() => getPlatform();

  dynamic listenContextMenu({required bool preventDefault});
}
