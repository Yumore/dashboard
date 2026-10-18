import 'package:dashboard/features/reading/book/entity/book.dart';

/// Detail-page / search-hit book metadata (hand-written JSON, no codegen).
class BookInfo {
  String id;
  String name;
  String author;
  String coverUrl;
  String category;
  String description;
  String status;
  String latestChapter;
  String updatedAt;
  double rating;
  int ratingCount;
  List<Book> relatedBooks;

  String sourceUrl;
  String bookUrl;
  String originName;
  String tocUrl;

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    final rawRelated = json['relatedBooks'];
    return BookInfo(
      id: _s(json['id']),
      name: _s(json['name']),
      author: _s(json['author']),
      coverUrl: _s(json['coverUrl']),
      category: _s(json['category']),
      description: _s(json['description']),
      status: _s(json['status']),
      latestChapter: _s(json['latestChapter']),
      updatedAt: _s(json['updatedAt']),
      rating: _d(json['rating']),
      ratingCount: _i(json['ratingCount']),
      relatedBooks: rawRelated is List
          ? rawRelated
              .whereType<Map>()
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const <Book>[],
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
        'status': status,
        'latestChapter': latestChapter,
        'updatedAt': updatedAt,
        'rating': rating,
        'ratingCount': ratingCount,
        'relatedBooks': relatedBooks.map((e) => e.toJson()).toList(),
        'sourceUrl': sourceUrl,
        'bookUrl': bookUrl,
        'originName': originName,
        'tocUrl': tocUrl,
      };

  BookInfo({
    this.id = '',
    this.name = '',
    this.author = '',
    this.coverUrl = '',
    this.category = '',
    this.description = '',
    this.status = '',
    this.latestChapter = '',
    this.updatedAt = '',
    this.rating = 0,
    this.ratingCount = 0,
    this.relatedBooks = const [],
    this.sourceUrl = '',
    this.bookUrl = '',
    this.originName = '',
    this.tocUrl = '',
  });

  BookInfo.id(this.id, this.name, this.coverUrl)
      : author = '',
        category = '',
        description = '',
        status = '',
        latestChapter = '',
        updatedAt = '',
        rating = 0,
        ratingCount = 0,
        relatedBooks = const [],
        sourceUrl = '',
        bookUrl = '',
        originName = '',
        tocUrl = '';

  Book toBook() {
    return Book(
      id: id,
      name: name,
      author: author,
      coverUrl: coverUrl,
      category: category,
      description: description,
      latestChapter: latestChapter,
      updatedAt: updatedAt,
      sourceUrl: sourceUrl,
      bookUrl: bookUrl,
      originName: originName,
      tocUrl: tocUrl,
    );
  }
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
