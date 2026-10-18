/// Atom `<category>` of a Feedbooks book entry, e.g.
/// `label="Short Story" term="FBFIC029000"`.
class FeedbooksCategory {
  FeedbooksCategory({this.label, this.term, this.scheme});

  FeedbooksCategory.fromJson(Map<String, dynamic> json) {
    label = json['label'] as String?;
    term = json['term'] as String?;
    scheme = json['scheme'] as String?;
  }

  String? label;
  String? term;
  String? scheme;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['term'] = term;
    data['scheme'] = scheme;
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksCategory(label: $label, term: $term, scheme: $scheme)';
  }
}
