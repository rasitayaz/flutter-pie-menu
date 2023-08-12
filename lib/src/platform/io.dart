import 'base.dart';

BasePlatform getPlatform() => _IOPlatform();

class _IOPlatform implements BasePlatform {
  @override
  dynamic listenContextMenu({required bool preventDefault}) {}
}
