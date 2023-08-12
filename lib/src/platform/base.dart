import 'platform.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.html) 'html.dart';

/// Base class for small platform specific implementations.
abstract class BasePlatform {
  factory BasePlatform() => getPlatform();

  /// Listens to the context menu event and
  /// optionally prevents the default behavior.
  dynamic listenContextMenu({required bool shouldPreventDefault});
}
