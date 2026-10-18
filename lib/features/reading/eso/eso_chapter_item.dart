/// 目录项（移植 eso `lib/database/chapter_item.dart`）。
class EsoChapterItem {
  EsoChapterItem({this.contentUrl, this.cover, this.name, this.time, this.url});

  String? contentUrl;
  String? cover;
  String? name;
  String? time;
  String? url;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'contentUrl': contentUrl,
        'cover': cover,
        'name': name,
        'time': time,
        'url': url,
      };

  EsoChapterItem.fromJson(Map<String, dynamic> json)
      : contentUrl = json['contentUrl'] as String?,
        cover = json['cover'] as String?,
        name = json['name'] as String?,
        time = json['time'] as String?,
        url = json['url'] as String?;
}
