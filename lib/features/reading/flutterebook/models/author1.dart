import 'package:dashboard/features/reading/flutterebook/models/id.dart';

/// Book entry author element. Feedbooks puts the author page url in `uri`, e.g.
/// `https://catalog.feedbooks.com/author/1234&lang=en`.
class FeedbooksAuthor1 {
  FeedbooksAuthor1({this.name, this.uri});

  FeedbooksAuthor1.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null
        ? FeedbooksId.fromJson(json['name'] as Map<String, dynamic>)
        : null;
    uri = json['uri'] != null
        ? FeedbooksId.fromJson(json['uri'] as Map<String, dynamic>)
        : null;
  }

  FeedbooksId? name;
  FeedbooksId? uri;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (uri != null) {
      data['uri'] = uri!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksAuthor1(name: $name, uri: $uri)';
  }
}
