
/// Legado-compatible book source (subset used by M1 engine).
class BookInfoRule {
  String init;
  String name;
  String author;
  String kind;
  String wordCount;
  String lastChapter;
  String intro;
  String coverUrl;
  String tocUrl;
  String canReName;

  BookInfoRule({
    this.init = '',
    this.name = '',
    this.author = '',
    this.kind = '',
    this.wordCount = '',
    this.lastChapter = '',
    this.intro = '',
    this.coverUrl = '',
    this.tocUrl = '',
    this.canReName = '',
  });

  factory BookInfoRule.fromJson(Map<String, dynamic> json) => BookInfoRule(
        init: (json['init'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        wordCount: (json['wordCount'] ?? '').toString(),
        lastChapter: (json['lastChapter'] ?? '').toString(),
        intro: (json['intro'] ?? '').toString(),
        coverUrl: (json['coverUrl'] ?? '').toString(),
        tocUrl: (json['tocUrl'] ?? '').toString(),
        canReName: (json['canReName'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'init': init,
        'name': name,
        'author': author,
        'kind': kind,
        'wordCount': wordCount,
        'lastChapter': lastChapter,
        'intro': intro,
        'coverUrl': coverUrl,
        'tocUrl': tocUrl,
        'canReName': canReName,
      };
}

