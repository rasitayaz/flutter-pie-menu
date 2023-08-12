import 'base.dart';

BasePlatform getPlatform() => _IOPlatform();

/// IO implementation of [BasePlatform].
class _IOPlatform implements BasePlatform {
  @override
  dynamic listenContextMenu({required bool shouldPreventDefault}) {}
}
