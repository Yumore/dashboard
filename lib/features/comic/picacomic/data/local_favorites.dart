import 'dart:convert';

import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/custom_comic.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ports `FavoriteType` from PicaComic lib/foundation/local_favorites.dart:34.
///
/// Note the source's own key table: `nhentai` is **6**, not 5 (local favourites
/// use a different enum than `HistoryType`). The port keeps those exact keys so
/// existing rows stay readable.
final class FavoriteType {
  static const FavoriteType picacg = FavoriteType(0);
  static const FavoriteType ehentai = FavoriteType(1);
  static const FavoriteType jm = FavoriteType(2);
  static const FavoriteType hitomi = FavoriteType(3);
  static const FavoriteType htManga = FavoriteType(4);
  static const FavoriteType nhentai = FavoriteType(6);

  static const List<String> _names = [
    'picacg',
    'ehentai',
    'jm',
    'hitomi',
    'htmanga',
    '**Unknown**',
    'nhentai',
  ];

  final int key;

  const FavoriteType(this.key);

  /// Maps a `ComicSource` key onto its local-favourite slot. User-JS sources
  /// fall back to [intKey] / the key's `hashCode`, exactly like
  /// `FavoriteType.comicSource` did in the source.
  static FavoriteType fromSourceKey(String sourceKey, [int? intKey]) {
    final index = _names.indexOf(sourceKey);
    if (index >= 0) return FavoriteType(index);
    return FavoriteType(intKey ?? sourceKey.hashCode);
  }

  /// `ComicType.name` / `ComicSource.name` in the source (local_favorites.dart:55-72).
  String get name => (key >= 0 && key < _names.length)
      ? _names[key]
      : '**Unknown**';

  /// The `ComicSource` key this favourite belongs to.
  String get sourceKey => name;

  bool get isBuiltIn => key >= 0 && key < _names.length;

  @override
  bool operator ==(Object other) => other is FavoriteType && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'FavoriteType($key)';
}

/// Ports `FavoriteItem` (local_favorites.dart:89). Column names are preserved:
/// `target`, `name`, `author`, `type`, `tags`, `cover_path`, `time`,
/// `display_order`.
class FavoriteItem {
  FavoriteItem({
    required this.target,
    required this.name,
    required this.author,
    required this.type,
    List<String>? tags,
    required this.coverPath,
    String? time,
    this.displayOrder = 0,
  }) : tags = tags ?? <String>[],
       time = time ?? DateTime.now().toIso8601String();

  factory FavoriteItem.fromMap(Map<dynamic, dynamic> map) => FavoriteItem(
    target: '${map['target'] ?? ''}',
    name: '${map['name'] ?? ''}',
    author: '${map['author'] ?? ''}',
    type: FavoriteType(map['type'] as int? ?? -1),
    tags: ((map['tags'] as List?) ?? const []).map((e) => '$e').toList(),
    coverPath: '${map['cover_path'] ?? ''}',
    time: '${map['time'] ?? ''}',
    displayOrder: map['display_order'] as int? ?? 0,
  );

  /// `FavoriteItem.fromComicInfo` equivalent — the host's local-favourites
  /// entry point.
  factory FavoriteItem.fromComicInfo(
    ComicInfoData comic, {
    required FavoriteType type,
    int displayOrder = 0,
  }) => FavoriteItem(
    target: comic.comicId,
    name: comic.title,
    author: comic.subTitle ?? '',
    type: type,
    tags: [
      for (final entry in comic.tags.entries)
        for (final value in entry.value) '${entry.key}:$value',
    ],
    coverPath: comic.cover,
    displayOrder: displayOrder,
  );

  String target;
  String name;
  String author;
  FavoriteType type;
  List<String> tags;
  String coverPath;
  String time;
  int displayOrder;

  /// `FavoriteItem.available` (local_favorites.dart:104).
  bool get available => type.isBuiltIn;

  /// Converts back for the UI layer.
  BaseComic toBaseComic() => CustomComic(
    name,
    author,
    coverPath,
    target,
    tags,
    '',
    type.sourceKey,
  );

  Map<String, dynamic> toMap() => {
    'target': target,
    'name': name,
    'author': author,
    'type': type.key,
    'tags': tags,
    'cover_path': coverPath,
    'time': time,
    'display_order': displayOrder,
  };

  @override
  String toString() => 'FavoriteItem($target, type=${type.key})';
}

/// Pairs a row with the folder it lives in (local_favorites.dart:256).
class FavoriteItemWithFolderInfo {
  const FavoriteItemWithFolderInfo(this.comic, this.folder);

  final FavoriteItem comic;
  final String folder;

  @override
  bool operator ==(Object other) =>
      other is FavoriteItemWithFolderInfo &&
      other.comic == comic &&
      other.folder == folder;

  @override
  int get hashCode => comic.hashCode ^ folder.hashCode;
}

/// Ports `LocalFavoritesManager` (local_favorites.dart:287).
///
/// Persistence deviation: the source created one sqlite3 table per folder plus
/// `folder_order`; the host has no sqlite3 package, so the same shape is stored
/// as a single JSON document under [storeKey]:
/// `{"folders": {folder: [row, ...]}, "order": {folder: int}}`. Folder names are
/// table names in the source, so they are preserved verbatim as JSON keys.
class LocalFavoritesManager {
  LocalFavoritesManager({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final LocalFavoritesManager instance = LocalFavoritesManager();

  static const String storeKey = 'content.picacomic.local_favorites.v1';

  /// The source's numeric default folder (`createFolder` renames empty/invalid
  /// names into the first free integer, local_favorites.dart:604-636).
  static const String defaultFolder = '0';

  final DateTime Function() _clock;
  Future<void> _pending = Future.value();

  Map<String, List<FavoriteItem>> _folders = {};
  Map<String, int> _order = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storeKey);
    if (raw == null || raw.isEmpty) return;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _folders = {
      for (final entry
          in (json['folders'] as Map<String, dynamic>? ?? {}).entries)
        entry.key: [
          for (final row in entry.value as List)
            FavoriteItem.fromMap(row as Map),
        ],
    };
    _order = {
      for (final entry in (json['order'] as Map<String, dynamic>? ?? {})
          .entries)
        entry.key: entry.value as int,
    };
  }

  /// Folders sorted by their stored order (local_favorites.dart:507-526).
  List<String> get folderNames {
    final names = _folders.keys.toList()
      ..sort((a, b) => (_order[a] ?? 0).compareTo(_order[b] ?? 0));
    return names;
  }

  int maxValue(String folder) {
    var max = 0;
    for (final item in _folders[folder] ?? const <FavoriteItem>[]) {
      if (item.displayOrder > max) max = item.displayOrder;
    }
    return max;
  }

  int minValue(String folder) {
    var min = 0;
    for (final item in _folders[folder] ?? const <FavoriteItem>[]) {
      if (item.displayOrder < min) min = item.displayOrder;
    }
    return min;
  }

  /// `createFolder` (local_favorites.dart:604-636): empty or duplicate names are
  /// renamed to the first free integer when [renameWhenInvalidName] is true, and
  /// otherwise throw.
  Future<String> createFolder(
    String name, [
    bool renameWhenInvalidName = false,
  ]) => _serialize(() async {
    if (name.isEmpty) {
      if (!renameWhenInvalidName) {
        throw Exception('name is empty!');
      }
      var i = 0;
      while (_folders.containsKey('$i')) {
        i++;
      }
      name = '$i';
    }
    if (_folders.containsKey(name)) {
      if (!renameWhenInvalidName) {
        throw Exception('Folder is existing');
      }
      final prevName = name;
      var i = 0;
      while (_folders.containsKey('$i')) {
        i++;
      }
      name = '$prevName$i';
    }
    _folders[name] = [];
    _order[name] = _order.length;
    await _save();
    return name;
  });

  Future<void> deleteFolder(String name) => _serialize(() async {
    _folders.remove(name);
    _order.remove(name);
    await _save();
  });

  Future<void> renameFolder(String name, String newName) => _serialize(() async {
    if (name == newName) return;
    if (_folders.containsKey(newName)) {
      throw Exception('Folder is existing');
    }
    final items = _folders.remove(name);
    if (items == null) return;
    _folders[newName] = items;
    _order[newName] = _order.remove(name) ?? _order.length;
    await _save();
  });

  Future<void> saveFolderOrder(List<String> folders) => _serialize(() async {
    for (var i = 0; i < folders.length; i++) {
      _order[folders[i]] = i;
    }
    await _save();
  });

  bool comicExists(String folder, String target, int type) =>
      (_folders[folder] ?? const <FavoriteItem>[]).any(
        (item) => item.target == target && item.type.key == type,
      );

  List<FavoriteItem> getAllComics(String folder) =>
      [...(_folders[folder] ?? const <FavoriteItem>[])]
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  List<FavoriteItemWithFolderInfo> allComics() => [
    for (final folder in folderNames)
      for (final comic in getAllComics(folder))
        FavoriteItemWithFolderInfo(comic, folder),
  ];

  /// `addComic` (local_favorites.dart:660-690): rows are keyed by
  /// `(target, type)`, and `display_order` continues past the current max.
  Future<void> addComic(String folder, FavoriteItem item) => _serialize(() async {
    final items = _folders.putIfAbsent(folder, () => []);
    items.removeWhere(
      (existing) =>
          existing.target == item.target && existing.type.key == item.type.key,
    );
    item.displayOrder = maxValue(folder) + 1;
    item.time = _clock().toIso8601String();
    items.add(item);
    await _save();
  });

  Future<void> removeComic(String folder, String target, int type) =>
      _serialize(() async {
        (_folders[folder] ?? const <FavoriteItem>[]).removeWhere(
          (item) => item.target == target && item.type.key == type,
        );
        await _save();
      });

  /// `find` (local_favorites.dart:369-380): every folder containing the row.
  List<String> find(String target, FavoriteType type) => [
    for (final folder in folderNames)
      if (comicExists(folder, target, type.key)) folder,
  ];

  bool isFavorite(String target, FavoriteType type) =>
      find(target, type).isNotEmpty;

  /// `addTagTo` (local_favorites.dart:583-589): the source prepended
  /// `'$tag,'` to the comma-joined tag column.
  Future<void> addTagTo(String folder, String target, String tag) =>
      _serialize(() async {
        for (final item in _folders[folder] ?? const <FavoriteItem>[]) {
          if (item.target == target) {
            item.tags = [tag, ...item.tags];
          }
        }
        await _save();
      });

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storeKey,
      jsonEncode({
        'folders': {
          for (final entry in _folders.entries)
            entry.key: [for (final item in entry.value) item.toMap()],
        },
        'order': _order,
      }),
    );
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then((_) {}, onError: (Object _) {});
    return result;
  }
}
