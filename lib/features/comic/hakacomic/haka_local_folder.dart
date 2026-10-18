/// A user-created local favourites folder
/// (`haka_comic/lib/database/local_favorites_helper.dart:30-60`).
///
/// Upstream stored the full comic document in the folder row, so the folder can
/// render offline without re-fetching; this port keeps that behaviour.
class HakaLocalFolder {
  const HakaLocalFolder({
    required this.name,
    required this.createdAt,
    this.comics = const [],
  });

  final String name;

  final int createdAt;

  /// Raw comic documents, in insertion order.
  final List<Map<String, dynamic>> comics;

  List<String> get comicIds =>
      comics.map((comic) => '${comic['_id']}').toList();

  HakaLocalFolder copyWith({String? name, List<Map<String, dynamic>>? comics}) {
    return HakaLocalFolder(
      name: name ?? this.name,
      createdAt: createdAt,
      comics: comics ?? this.comics,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'created_at': createdAt,
    'comics': comics,
  };

  factory HakaLocalFolder.fromJson(Map<String, dynamic> json) {
    return HakaLocalFolder(
      name: json['name'] as String,
      createdAt: json['created_at'] as int,
      comics: (json['comics'] as List<dynamic>? ?? const [])
          .map((comic) => Map<String, dynamic>.from(comic as Map))
          .toList(),
    );
  }
}
