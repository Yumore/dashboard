/// Episode metadata returned alongside chapter images
/// (`haka_comic/lib/network/models.dart:1054-1067`).
class HakaChapterEpisode {
  const HakaChapterEpisode({required this.id, required this.title});

  final String id;

  final String title;

  factory HakaChapterEpisode.fromJson(Map<String, dynamic> json) {
    return HakaChapterEpisode(
      id: json['_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'title': title};
}
