import 'dart:io';

/// Filename rules ported from the source download manager.
///
/// The source replaced every character of `[\\/:*?"<>|]` with `_` and added a
/// numeric suffix when a file already existed. Two small hardening deviations
/// are applied here: surrounding whitespace is trimmed and an empty name falls
/// back to `video` instead of producing a hidden `.mp4` file.
class YoutubeDlFileName {
  const YoutubeDlFileName._();

  static final RegExp invalidChars = RegExp(r'[\\/:*?"<>|]');
  static final RegExp _collisionSuffix = RegExp(r' \([0-9]+\)$');

  static String sanitize(String title) {
    final replaced = title.replaceAll(invalidChars, '_').trim();
    return replaced.isEmpty ? 'video' : replaced;
  }

  static String withExtension(String title, String extension) {
    final normalized = extension.startsWith('.')
        ? extension.substring(1)
        : extension;
    final safeTitle = sanitize(title);
    return normalized.isEmpty ? safeTitle : '$safeTitle.$normalized';
  }

  static String join(String directory, String name) {
    if (directory.endsWith(Platform.pathSeparator) || directory.endsWith('/')) {
      return '$directory$name';
    }
    return '$directory${Platform.pathSeparator}$name';
  }

  /// Source-compatible temp filename (`Unconfirmed 7.ytdownload[.mp4]`).
  static String tempName(int id, {String? container}) {
    if (container == null || container.isEmpty) {
      return 'Unconfirmed $id.ytdownload';
    }
    return 'Unconfirmed $id.ytdownload.$container';
  }

  /// Mirrors the source's `getValidPath` collision suffix logic.
  ///
  /// Given `/tmp/a (7).mp4` and `count == 1` this returns `/tmp/a (1).mp4`,
  /// because the pre-existing suffix is stripped before numbering.
  static String collisionCandidate(String path, int count) {
    final separatorIndex = _lastSeparatorIndex(path);
    final dotIndex = path.lastIndexOf('.');
    final hasExtension = dotIndex > separatorIndex;
    final base = hasExtension ? path.substring(0, dotIndex) : path;
    final extension = hasExtension ? path.substring(dotIndex) : '';
    final stripped = base.replaceFirst(_collisionSuffix, '');
    return '$stripped ($count)$extension';
  }

  static int _lastSeparatorIndex(String path) {
    final forward = path.lastIndexOf('/');
    final backward = path.lastIndexOf(Platform.pathSeparator);
    return forward > backward ? forward : backward;
  }
}
