/// Atom link of a book entry.
///
/// Feedbooks orders the entry links as:
/// `[0]` alternate html page, `[1]` cover image, `[2]` thumbnail,
/// `[3]` acquisition (`application/epub+zip`).
class FeedbooksLink1 {
  FeedbooksLink1({this.type, this.rel, this.title, this.href});

  FeedbooksLink1.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    rel = json['rel'] as String?;
    title = json['title'] as String?;
    href = json['href'] as String?;
  }

  String? type;
  String? rel;
  String? title;
  String? href;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['rel'] = rel;
    data['title'] = title;
    data['href'] = href;
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksLink1(type: $type, rel: $rel, title: $title, href: $href)';
  }
}
