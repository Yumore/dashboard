import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user-configurable folders that hold episode-note images and covers, with
/// relative/absolute path translation.
///
/// The source app persisted only the *root* folder path and stored every image
/// as a path relative to it, so moving the folder keeps all notes readable. The
/// port keeps that model but resolves the default root through `path_provider`
/// instead of a per-platform constant table, and namespaces the preference keys
/// so the host's other features are never touched.
class AnimeTraceImageStore {
  AnimeTraceImageStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String noteImageRootKey = 'animetrace.noteImageRootDirPath';
  static const String coverImageRootKey = 'animetrace.coverImageRootDirPath';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  /// Folder holding note images; falls back to
  /// `<documents>/animetrace/note_images` when the user has not chosen one.
  Future<String> noteImageRootDirPath() async {
    final prefs = await _prefs;
    final configured = prefs.getString(noteImageRootKey);
    if (configured != null && configured.isNotEmpty) return configured;
    return _defaultRoot('note_images');
  }

  Future<bool> hasNoteImageRootDirPath() async {
    final prefs = await _prefs;
    final configured = prefs.getString(noteImageRootKey);
    return configured != null && configured.isNotEmpty;
  }

  Future<void> setNoteImageRootDirPath(String path) async {
    final prefs = await _prefs;
    await prefs.setString(noteImageRootKey, normalizeRoot(path));
  }

  /// Folder holding locally saved covers (used when a cover is downloaded for
  /// offline use).
  Future<String> coverImageRootDirPath() async {
    final prefs = await _prefs;
    final configured = prefs.getString(coverImageRootKey);
    if (configured != null && configured.isNotEmpty) return configured;
    return _defaultRoot('cover_images');
  }

  Future<void> setCoverImageRootDirPath(String path) async {
    final prefs = await _prefs;
    await prefs.setString(coverImageRootKey, normalizeRoot(path));
  }

  /// Copies [sourceAbsolutePath] into the note-image folder and returns the
  /// path **relative** to that folder, which is what the `image` table stores.
  Future<String> saveNoteImage(
    String sourceAbsolutePath, {
    String? root,
  }) async {
    final rootDir = root ?? await noteImageRootDirPath();
    final directory = Directory(rootDir);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    final source = File(sourceAbsolutePath);
    final baseName = sourceAbsolutePath.split(Platform.pathSeparator).last;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${stamp}_$baseName';
    final target = File(joinPath(rootDir, fileName));
    await source.copy(target.path);
    return fileName;
  }

  /// Deletes the file behind [relativePath] (best effort).
  Future<bool> deleteNoteImage(String relativePath, {String? root}) async {
    final rootDir = root ?? await noteImageRootDirPath();
    final file = File(absolutePathOf(relativePath, rootDir));
    if (!file.existsSync()) return false;
    await file.delete();
    return true;
  }

  /// Absolute path of [relativePath] inside [root].
  static String absolutePathOf(String relativePath, String root) {
    if (relativePath.isEmpty) return '';
    if (isAbsolutePath(relativePath)) return relativePath;
    return joinPath(normalizeRoot(root), relativePath);
  }

  /// [absolutePath] expressed relative to [root]; returns the input unchanged
  /// when it is not inside [root].
  static String relativePathOf(String absolutePath, String root) {
    if (absolutePath.isEmpty) return '';
    final normalizedRoot = normalizeRoot(root);
    if (normalizedRoot.isEmpty) return absolutePath;
    final prefix = normalizedRoot.endsWith('/')
        ? normalizedRoot
        : '$normalizedRoot/';
    if (absolutePath.startsWith(prefix)) {
      return absolutePath.substring(prefix.length);
    }
    return absolutePath;
  }

  /// Strips a trailing separator and normalizes separators to `/`.
  static String normalizeRoot(String path) {
    var normalized = path.trim().replaceAll('\\', '/');
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  static bool isAbsolutePath(String path) =>
      path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);

  static String joinPath(String left, String right) {
    final normalizedLeft = normalizeRoot(left);
    var normalizedRight = right.replaceAll('\\', '/');
    while (normalizedRight.startsWith('/')) {
      normalizedRight = normalizedRight.substring(1);
    }
    if (normalizedLeft.isEmpty) return normalizedRight;
    return '$normalizedLeft/$normalizedRight';
  }

  Future<String> _defaultRoot(String folder) async {
    final documents = await getApplicationDocumentsDirectory();
    return joinPath(joinPath(documents.path, 'animetrace'), folder);
  }
}
