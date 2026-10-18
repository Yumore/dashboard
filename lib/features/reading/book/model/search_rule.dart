
/// Legado-compatible book source (subset used by M1 engine).
class SearchRule {
  String bookList;
  String name;
  String author;
  String kind;
  String wordCount;
  String lastChapter;
  String intro;
  String coverUrl;
  String bookUrl;
  String checkKeyWord;

  SearchRule({
    this.bookList = '',
    this.name = '',
    this.author = '',
    this.kind = '',
    this.wordCount = '',
    this.lastChapter = '',
    this.intro = '',
    this.coverUrl = '',
    this.bookUrl = '',
    this.checkKeyWord = '',
  });

  factory SearchRule.fromJson(Map<String, dynamic> json) => SearchRule(
        bookList: (json['bookList'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        wordCount: (json['wordCount'] ?? '').toString(),
        lastChapter: (json['lastChapter'] ?? '').toString(),
        intro: (json['intro'] ?? '').toString(),
        coverUrl: (json['coverUrl'] ?? '').toString(),
        bookUrl: (json['bookUrl'] ?? '').toString(),
        checkKeyWord: (json['checkKeyWord'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'bookList': bookList,
        'name': name,
        'author': author,
        'kind': kind,
        'wordCount': wordCount,
        'lastChapter': lastChapter,
        'intro': intro,
        'coverUrl': coverUrl,
        'bookUrl': bookUrl,
        'checkKeyWord': checkKeyWord,
      };
}

