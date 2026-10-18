import 'dart:convert';

import 'package:dashboard/features/comic/hakacomic/haka_local_folder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local favourites: named folders plus full comic documents.
///
/// Deliberate deviation: upstream used sqflite with two tables
/// (`haka_comic/lib/database/local_favorites_helper.dart`); the semantics kept
/// here are: folders are listed oldest-first, the [defaultFolderName] folder
/// always exists, adding an already-present comic is a no-op, and the default
/// folder cannot be renamed or removed.
class HakaFavoriteStore {
  HakaFavoriteStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'hakacomic_favourite_folders';

  /// Upstream seeded a default folder named `default`
  /// (`local_favorites_helper.dart:20`).
  static const String defaultFolderName = 'default';

  List<HakaLocalFolder> _read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [_seedDefault()];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    final folders = decoded
        .map((item) => HakaLocalFolder.fromJson(item as Map<String, dynamic>))
        .toList();
    if (!folders.any((folder) => folder.name == defaultFolderName)) {
      folders.insert(0, _seedDefault());
    }
    return folders;
  }

  HakaLocalFolder _seedDefault() => HakaLocalFolder(
    name: defaultFolderName,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );

  Future<void> _write(List<HakaLocalFolder> folders) {
    return _prefs.setString(
      storageKey,
      jsonEncode(folders.map((folder) => folder.toJson()).toList()),
    );
  }

  Future<List<HakaLocalFolder>> folders() async => _read();

  Future<bool> createFolder(String name) async {
    final folders = _read();
    if (name.isEmpty || folders.any((folder) => folder.name == name)) {
      return false;
    }
    folders.add(
      HakaLocalFolder(
        name: name,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _write(folders);
    return true;
  }

  /// The default folder cannot be removed.
  Future<bool> deleteFolder(String name) async {
    if (name == defaultFolderName) return false;
    final folders = _read();
    final next = folders.where((folder) => folder.name != name).toList();
    if (next.length == folders.length) return false;
    await _write(next);
    return true;
  }

  Future<bool> renameFolder(String from, String to) async {
    if (from == defaultFolderName || to.isEmpty) return false;
    final folders = _read();
    if (folders.any((folder) => folder.name == to)) return false;
    final index = folders.indexWhere((folder) => folder.name == from);
    if (index < 0) return false;
    folders[index] = folders[index].copyWith(name: to);
    await _write(folders);
    return true;
  }

  Future<List<Map<String, dynamic>>> comicsIn(String folder) async {
    final folders = _read();
    final index = folders.indexWhere((item) => item.name == folder);
    return index < 0 ? const [] : folders[index].comics;
  }

  Future<bool> contains(String folder, String comicId) async {
    return (await comicsIn(folder)).any((comic) => '${comic['_id']}' == comicId);
  }

  /// Adds [comic] to [folder]; returns `true` when the folder changed.
  Future<bool> addComic(
    String folder,
    Map<String, dynamic> comic,
    String comicId,
  ) async {
    final folders = _read();
    final index = folders.indexWhere((item) => item.name == folder);
    if (index < 0) return false;
    final comics = folders[index].comics;
    if (comics.any((item) => '${item['_id']}' == comicId)) return false;
    folders[index] = folders[index].copyWith(comics: [...comics, comic]);
    await _write(folders);
    return true;
  }

  Future<bool> removeComic(String folder, String comicId) async {
    final folders = _read();
    final index = folders.indexWhere((item) => item.name == folder);
    if (index < 0) return false;
    final comics = folders[index].comics;
    if (!comics.any((item) => '${item['_id']}' == comicId)) return false;
    folders[index] = folders[index].copyWith(
      comics: comics.where((item) => '${item['_id']}' != comicId).toList(),
    );
    await _write(folders);
    return true;
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
