/// Local shelf / reading-session book row.
///
/// Hand-written JSON mapping replaces the source project's
/// `json_serializable` code generation (the host forbids build_runner).
/// Keys match the generated wire format: the Dart field names themselves.
class Book {
  String id;
  String name;
  String author;
  String coverUrl;
  String category;
  String description;

  /// Chapter currently being read (display title).
  String readingChapter;

  /// Newest chapter title known for the book.
  String latestChapter;

  int chapterIndex;
  int pageIndex;
  double scrollOffset;
  int sortTime;

  /// Non-zero means shelf shows update badge.
  int hasUpdate;

  String updatedAt;

  /// Active book source url (Legado bookSourceUrl).
  String sourceUrl;

  /// Book detail / info page url on the source site.
  String bookUrl;

  /// Cached display name of the source.
  String originName;

  /// Optional toc url override.
  String tocUrl;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: _s(json['id']),
      name: _s(json['name']),
      author: _s(json['author']),
      coverUrl: _s(json['coverUrl']),
      category: _s(json['category']),
      description: _s(json['description']),
      readingChapter: _s(json['readingChapter']),
      latestChapter: _s(json['latestChapter']),
      chapterIndex: _i(json['chapterIndex']),
      pageIndex: _i(json['pageIndex']),
      scrollOffset: _d(json['scrollOffset']),
      sortTime: _i(json['sortTime']),
      hasUpdate: _i(json['hasUpdate']),
      updatedAt: _s(json['updatedAt']),
      sourceUrl: _s(json['sourceUrl']),
      bookUrl: _s(json['bookUrl']),
      originName: _s(json['originName']),
      tocUrl: _s(json['tocUrl']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'author': author,
        'coverUrl': coverUrl,
        'category': category,
        'description': description,
        'readingChapter': readingChapter,
        'latestChapter': latestChapter,
        'chapterIndex': chapterIndex,
        'pageIndex': pageIndex,
        'scrollOffset': scrollOffset,
        'sortTime': sortTime,
        'hasUpdate': hasUpdate,
        'updatedAt': updatedAt,
        'sourceUrl': sourceUrl,
        'bookUrl': bookUrl,
        'originName': originName,
        'tocUrl': tocUrl,
      };

  Book({
    this.id = '',
    this.name = '',
    this.author = '',
    this.coverUrl = '',
    this.category = '',
    this.description = '',
    this.readingChapter = '',
    this.latestChapter = '',
    this.chapterIndex = 0,
    this.pageIndex = 0,
    this.scrollOffset = 0,
    this.sortTime = 0,
    this.hasUpdate = 0,
    this.updatedAt = '',
    this.sourceUrl = '',
    this.bookUrl = '',
    this.originName = '',
    this.tocUrl = '',
  });

  Book.id(this.id)
      : name = '',
        author = '',
        coverUrl = '',
        category = '',
        description = '',
        readingChapter = '',
        latestChapter = '',
        chapterIndex = 0,
        pageIndex = 0,
        scrollOffset = 0,
        sortTime = 0,
        hasUpdate = 0,
        updatedAt = '',
        sourceUrl = '',
        bookUrl = '',
        originName = '',
        tocUrl = '';

  Book.cover(this.coverUrl)
      : id = '',
        name = '',
        author = '',
        category = '',
        description = '',
        readingChapter = '',
        latestChapter = '',
        chapterIndex = 0,
        pageIndex = 0,
        scrollOffset = 0,
        sortTime = 0,
        hasUpdate = 0,
        updatedAt = '',
        sourceUrl = '',
        bookUrl = '',
        originName = '',
        tocUrl = '';
}

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());

int _i(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _d(Object? v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
