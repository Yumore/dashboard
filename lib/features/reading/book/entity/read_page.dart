import 'package:dashboard/features/reading/book/entity/text_page.dart';

/// Persisted pagination result for one chapter (hand-written JSON, no codegen).
class ReadPage {
  int get pageOffsets => pages.length;
  List<TextPage> pages;
  String chapterContent;
  double height;
  String chapterName;

  ReadPage.kong()
      : pages = const [],
        chapterContent = '',
        height = 0,
        chapterName = '';

  ReadPage(this.chapterContent, this.chapterName, this.height, this.pages);

  factory ReadPage.fromJson(Map<String, dynamic> json) {
    final rawPages = json['pages'];
    return ReadPage(
      _s(json['chapterContent']),
      _s(json['chapterName']),
      _d(json['height']),
      rawPages is List
          ? rawPages
              .whereType<Map>()
              .map((e) => TextPage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const <TextPage>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pages': pages.map((e) => e.toJson()).toList(),
        'chapterContent': chapterContent,
        'height': height,
        'chapterName': chapterName,
      };
}

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());

double _d(Object? v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
