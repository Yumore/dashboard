class U17Comic {
  const U17Comic({
    required this.id,
    required this.name,
    this.cover,
    this.description = '',
    this.author = '',
    this.tags = const [],
    this.updatedAt,
  });

  final int id;
  final String name;
  final Uri? cover;
  final String description;
  final String author;
  final List<String> tags;
  final DateTime? updatedAt;

  factory U17Comic.fromJson(Map<String, dynamic> json) {
    final cover = '${json['cover'] ?? ''}';
    final seconds = int.tryParse('${json['last_update_time']}');
    return U17Comic(
      id: int.tryParse('${json['comic_id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? ''}',
      cover: cover.isEmpty ? null : Uri.tryParse(cover),
      description: '${json['description'] ?? json['short_description'] ?? ''}',
      author: json['author'] is Map ? '${json['author']['name'] ?? ''}' : '',
      tags: (json['theme_ids'] is List ? json['theme_ids'] as List : const [])
          .map((value) => value.toString())
          .toList(),
      updatedAt: seconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
    );
  }

  Map<String, Object?> toJson() => {
    'comic_id': id,
    'name': name,
    'cover': cover?.toString(),
    'description': description,
    'author': {'name': author},
    'theme_ids': tags,
    'last_update_time': updatedAt == null
        ? null
        : updatedAt!.millisecondsSinceEpoch ~/ 1000,
  };
}
