import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// `GET keywords` payload (`haka_comic/lib/network/models.dart:1374-1384`).
class HakaHotSearchWordsResponse {
  const HakaHotSearchWordsResponse({required this.keywords});

  final List<String> keywords;

  factory HakaHotSearchWordsResponse.fromJson(Map<String, dynamic> json) {
    return HakaHotSearchWordsResponse(
      keywords: hakaStringList(json['keywords']),
    );
  }

  Map<String, dynamic> toJson() => {'keywords': keywords};
}
