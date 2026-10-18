import 'package:dashboard/features/reading/flutterebook/models/author1.dart';
import 'package:dashboard/features/reading/flutterebook/models/category.dart';
import 'package:dashboard/features/reading/flutterebook/models/id.dart';
import 'package:dashboard/features/reading/flutterebook/models/link1.dart';
import 'package:dashboard/features/reading/flutterebook/models/schema_series.dart';

/// One book of a Feedbooks atom feed.
///
/// Two single-vs-list normalisations are inherited from the source model and
/// matter on real feeds (a feed with one book emits `<entry>` once, so the
/// transform yields a map, not a list):
///  * `author` is read as `json['author'][0]` first and falls back to the whole
///    map when that throws;
///  * `category` and the feed's `entry` list do the same with `forEach`;
///  * `link` uses a bare `try/catch (_) {}`, so a *single* link leaves
///    [link] as an empty list rather than a one element list.
class FeedbooksEntry {
  FeedbooksEntry({
    this.title,
    this.id,
    this.author,
    this.published,
    this.updated,
    this.dctermsLanguage,
    this.dctermsPublisher,
    this.dctermsIssued,
    this.summary,
    this.category,
    this.link,
    this.schemaSeries,
  });

  FeedbooksEntry.fromJson(Map<String, dynamic> json) {
    title = json['title'] != null
        ? FeedbooksId.fromJson(json['title'] as Map<String, dynamic>)
        : null;
    id = json['id'] != null
        ? FeedbooksId.fromJson(json['id'] as Map<String, dynamic>)
        : null;
    if (json['author'] != null) {
      try {
        author = FeedbooksAuthor1.fromJson(json['author'][0] as Map<String, dynamic>);
      } catch (_) {
        author = FeedbooksAuthor1.fromJson(json['author'] as Map<String, dynamic>);
      }
    }
    published = json['published'] != null
        ? FeedbooksId.fromJson(json['published'] as Map<String, dynamic>)
        : null;
    updated = json['updated'] != null
        ? FeedbooksId.fromJson(json['updated'] as Map<String, dynamic>)
        : null;
    dctermsLanguage = json[r'dcterms$language'] != null
        ? FeedbooksId.fromJson(json[r'dcterms$language'] as Map<String, dynamic>)
        : null;
    dctermsPublisher = json[r'dcterms$publisher'] != null
        ? FeedbooksId.fromJson(json[r'dcterms$publisher'] as Map<String, dynamic>)
        : null;
    dctermsIssued = json[r'dcterms$issued'] != null
        ? FeedbooksId.fromJson(json[r'dcterms$issued'] as Map<String, dynamic>)
        : null;
    summary = json['summary'] != null
        ? FeedbooksId.fromJson(json['summary'] as Map<String, dynamic>)
        : null;
    if (json['category'] != null) {
      category = <FeedbooksCategory>[];
      try {
        json['category'].forEach((v) {
          category!.add(FeedbooksCategory.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {
        category!.add(
          FeedbooksCategory.fromJson(json['category'] as Map<String, dynamic>),
        );
      }
    }
    if (json['link'] != null) {
      link = <FeedbooksLink1>[];
      try {
        json['link'].forEach((v) {
          link!.add(FeedbooksLink1.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {}
    }
    schemaSeries = json[r'schema$Series'] != null
        ? FeedbooksSchemaSeries.fromJson(json[r'schema$Series'] as Map<String, dynamic>)
        : null;
  }

  FeedbooksId? title;
  FeedbooksId? id;
  FeedbooksAuthor1? author;
  FeedbooksId? published;
  FeedbooksId? updated;
  FeedbooksId? dctermsLanguage;
  FeedbooksId? dctermsPublisher;
  FeedbooksId? dctermsIssued;
  FeedbooksId? summary;
  List<FeedbooksCategory>? category;
  List<FeedbooksLink1>? link;
  FeedbooksSchemaSeries? schemaSeries;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (id != null) {
      data['id'] = id!.toJson();
    }
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (published != null) {
      data['published'] = published!.toJson();
    }
    if (updated != null) {
      data['updated'] = updated!.toJson();
    }
    if (dctermsLanguage != null) {
      data[r'dcterms$language'] = dctermsLanguage!.toJson();
    }
    if (dctermsPublisher != null) {
      data[r'dcterms$publisher'] = dctermsPublisher!.toJson();
    }
    if (dctermsIssued != null) {
      data[r'dcterms$issued'] = dctermsIssued!.toJson();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (link != null) {
      data['link'] = link!.map((v) => v.toJson()).toList();
    }
    if (schemaSeries != null) {
      data[r'schema$Series'] = schemaSeries!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksEntry(title: $title, id: $id, author: $author, published: $published, updated: $updated, dctermsLanguage: $dctermsLanguage, dctermsPublisher: $dctermsPublisher, dctermsIssued: $dctermsIssued, summary: $summary, category: $category, link: $link, schemaSeries: $schemaSeries)';
  }
}
