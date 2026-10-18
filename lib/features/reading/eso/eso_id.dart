import 'dart:math';

/// 手写的 UUID v4 生成器，替代 eso 使用的 `package:uuid`
/// （宿主的根 pubspec 中没有该依赖，故不新增依赖）。
class EsoId {
  const EsoId._();

  static final Random _random = Random.secure();
  static final RegExp _uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  static String v4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static bool isV4(String value) => _uuidV4.hasMatch(value);
}
