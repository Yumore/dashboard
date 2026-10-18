
/// Legado-compatible book source (subset used by M1 engine).
class TocRule {
  String chapterList;
  String chapterName;
  String chapterUrl;
  String isVolume;
  String updateTime;
  String nextTocUrl;

  TocRule({
    this.chapterList = '',
    this.chapterName = '',
    this.chapterUrl = '',
    this.isVolume = '',
    this.updateTime = '',
    this.nextTocUrl = '',
  });

  factory TocRule.fromJson(Map<String, dynamic> json) => TocRule(
        chapterList: (json['chapterList'] ?? '').toString(),
        chapterName: (json['chapterName'] ?? '').toString(),
        chapterUrl: (json['chapterUrl'] ?? '').toString(),
        isVolume: (json['isVolume'] ?? '').toString(),
        updateTime: (json['updateTime'] ?? '').toString(),
        nextTocUrl: (json['nextTocUrl'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'chapterList': chapterList,
        'chapterName': chapterName,
        'chapterUrl': chapterUrl,
        'isVolume': isVolume,
        'updateTime': updateTime,
        'nextTocUrl': nextTocUrl,
      };
}

