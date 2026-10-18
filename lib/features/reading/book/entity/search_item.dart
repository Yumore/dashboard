/// Search / explore list row (local book-source hit).
///
/// Hand-written JSON mapping replaces `json_serializable` codegen; keys are the
/// Dart field names, matching the generated wire format.
class SearchItem {
  String id;
  String name;
  String author;
  String coverUrl;
  String description;
  String status;
  String latestChapter;
  String category;
  String updatedAt;

  String sourceUrl;
  String bookUrl;
  String sourceName;

  SearchItem({
    this.id = '',
    this.name = '',
    this.author = '',
    this.coverUrl = '',
    this.description = '',
    this.status = '',
    this.latestChapter = '',
    this.category = '',
    this.updatedAt = '',
    this.sourceUrl = '',
    this.bookUrl = '',
    this.sourceName = '',
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: _s(json['id']),
      name: _s(json['name']),
      author: _s(json['author']),
      coverUrl: _s(json['coverUrl']),
      description: _s(json['description']),
      status: _s(json['status']),
      latestChapter: _s(json['latestChapter']),
      category: _s(json['category']),
      updatedAt: _s(json['updatedAt']),
      sourceUrl: _s(json['sourceUrl']),
      bookUrl: _s(json['bookUrl']),
      sourceName: _s(json['sourceName']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'author': author,
        'coverUrl': coverUrl,
        'description': description,
        'status': status,
        'latestChapter': latestChapter,
        'category': category,
        'updatedAt': updatedAt,
        'sourceUrl': sourceUrl,
        'bookUrl': bookUrl,
        'sourceName': sourceName,
      };
}

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());
