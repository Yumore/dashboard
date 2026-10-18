import 'package:dashboard/features/reading/flutterebook/models/author.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/models/id.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';

/// Root `<feed>` of a Feedbooks OPDS/atom browse document.
///
/// `opensearch:totalResults`, `opensearch:itemsPerPage` and
/// `opensearch:startIndex` drive the paging rules of the genre screen.
class FeedbooksFeed {
  FeedbooksFeed({
    this.xmlLang,
    this.xmlns,
    this.xmlnsDcterms,
    this.xmlnsThr,
    this.xmlnsApp,
    this.xmlnsOpensearch,
    this.xmlnsOpds,
    this.xmlnsXsi,
    this.xmlnsOdl,
    this.xmlnsSchema,
    this.id,
    this.title,
    this.updated,
    this.icon,
    this.author,
    this.link,
    this.opensearchTotalResults,
    this.opensearchItemsPerPage,
    this.opensearchStartIndex,
    this.entry,
  });

  FeedbooksFeed.fromJson(Map<String, dynamic> json) {
    xmlLang = json['xml:lang'] as String?;
    xmlns = json['xmlns'] as String?;
    xmlnsDcterms = json[r'xmlns$dcterms'] as String?;
    xmlnsThr = json[r'xmlns$thr'] as String?;
    xmlnsApp = json[r'xmlns$app'] as String?;
    xmlnsOpensearch = json[r'xmlns$opensearch'] as String?;
    xmlnsOpds = json[r'xmlns$opds'] as String?;
    xmlnsXsi = json[r'xmlns$xsi'] as String?;
    xmlnsOdl = json[r'xmlns$odl'] as String?;
    xmlnsSchema = json[r'xmlns$schema'] as String?;
    id = json['id'] != null
        ? FeedbooksId.fromJson(json['id'] as Map<String, dynamic>)
        : null;
    title = json['title'] != null
        ? FeedbooksId.fromJson(json['title'] as Map<String, dynamic>)
        : null;
    updated = json['updated'] != null
        ? FeedbooksId.fromJson(json['updated'] as Map<String, dynamic>)
        : null;
    icon = json['icon'] != null
        ? FeedbooksId.fromJson(json['icon'] as Map<String, dynamic>)
        : null;
    author = json['author'] != null
        ? FeedbooksAuthor.fromJson(json['author'] as Map<String, dynamic>)
        : null;
    if (json['link'] != null) {
      link = <FeedbooksLink>[];
      json['link'].forEach((v) {
        link!.add(FeedbooksLink.fromJson(v as Map<String, dynamic>));
      });
    }
    opensearchTotalResults = json[r'opensearch$totalResults'] != null
        ? FeedbooksId.fromJson(json[r'opensearch$totalResults'] as Map<String, dynamic>)
        : null;
    opensearchItemsPerPage = json[r'opensearch$itemsPerPage'] != null
        ? FeedbooksId.fromJson(json[r'opensearch$itemsPerPage'] as Map<String, dynamic>)
        : null;
    opensearchStartIndex = json[r'opensearch$startIndex'] != null
        ? FeedbooksId.fromJson(json[r'opensearch$startIndex'] as Map<String, dynamic>)
        : null;
    if (json['entry'] != null) {
      try {
        entry = <FeedbooksEntry>[];
        json['entry'].forEach((v) {
          entry!.add(FeedbooksEntry.fromJson(v as Map<String, dynamic>));
        });
      } catch (_) {
        entry = <FeedbooksEntry>[];
        entry!.add(FeedbooksEntry.fromJson(json['entry'] as Map<String, dynamic>));
      }
    }
  }

  String? xmlLang;
  String? xmlns;
  String? xmlnsDcterms;
  String? xmlnsThr;
  String? xmlnsApp;
  String? xmlnsOpensearch;
  String? xmlnsOpds;
  String? xmlnsXsi;
  String? xmlnsOdl;
  String? xmlnsSchema;
  FeedbooksId? id;
  FeedbooksId? title;
  FeedbooksId? updated;
  FeedbooksId? icon;
  FeedbooksAuthor? author;
  List<FeedbooksLink>? link;
  FeedbooksId? opensearchTotalResults;
  FeedbooksId? opensearchItemsPerPage;
  FeedbooksId? opensearchStartIndex;
  List<FeedbooksEntry>? entry;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xml:lang'] = xmlLang;
    data['xmlns'] = xmlns;
    data[r'xmlns$dcterms'] = xmlnsDcterms;
    data[r'xmlns$thr'] = xmlnsThr;
    data[r'xmlns$app'] = xmlnsApp;
    data[r'xmlns$opensearch'] = xmlnsOpensearch;
    data[r'xmlns$opds'] = xmlnsOpds;
    data[r'xmlns$xsi'] = xmlnsXsi;
    data[r'xmlns$odl'] = xmlnsOdl;
    data[r'xmlns$schema'] = xmlnsSchema;
    if (id != null) {
      data['id'] = id!.toJson();
    }
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (updated != null) {
      data['updated'] = updated!.toJson();
    }
    if (icon != null) {
      data['icon'] = icon!.toJson();
    }
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (link != null) {
      data['link'] = link!.map((v) => v.toJson()).toList();
    }
    if (opensearchTotalResults != null) {
      data[r'opensearch$totalResults'] = opensearchTotalResults!.toJson();
    }
    if (opensearchItemsPerPage != null) {
      data[r'opensearch$itemsPerPage'] = opensearchItemsPerPage!.toJson();
    }
    if (opensearchStartIndex != null) {
      data[r'opensearch$startIndex'] = opensearchStartIndex!.toJson();
    }
    if (entry != null) {
      data['entry'] = entry!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksFeed(xmlLang: $xmlLang, xmlns: $xmlns, xmlnsDcterms: $xmlnsDcterms, xmlnsThr: $xmlnsThr, xmlnsApp: $xmlnsApp, xmlnsOpensearch: $xmlnsOpensearch, xmlnsOpds: $xmlnsOpds, xmlnsXsi: $xmlnsXsi, xmlnsOdl: $xmlnsOdl, xmlnsSchema: $xmlnsSchema, id: $id, title: $title, updated: $updated, icon: $icon, author: $author, link: $link, opensearchTotalResults: $opensearchTotalResults, opensearchItemsPerPage: $opensearchItemsPerPage, opensearchStartIndex: $opensearchStartIndex, entry: $entry)';
  }
}
