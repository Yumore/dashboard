/// FeedbooksFeed level atom link. Feedbooks exposes the browse facets (genres, awards,
/// selections) as links carrying `opds:activeFacet`, `opds:facetGroup` and
/// `thr:count`, plus the `opensearch` paging links (`rel="next"`,
/// `rel="first"`, `rel="last"`).
class FeedbooksLink {
  FeedbooksLink({
    this.rel,
    this.type,
    this.href,
    this.title,
    this.opdsActiveFacet,
    this.opdsFacetGroup,
    this.thrCount,
  });

  FeedbooksLink.fromJson(Map<String, dynamic> json) {
    rel = json['rel'] as String?;
    type = json['type'] as String?;
    href = json['href'] as String?;
    title = json['title'] as String?;
    opdsActiveFacet = json['opds:activeFacet'] as String?;
    opdsFacetGroup = json['opds:facetGroup'] as String?;
    thrCount = json['thr:count'] as String?;
  }

  String? rel;
  String? type;
  String? href;
  String? title;
  String? opdsActiveFacet;
  String? opdsFacetGroup;
  String? thrCount;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rel'] = rel;
    data['type'] = type;
    data['href'] = href;
    data['title'] = title;
    data['opds:activeFacet'] = opdsActiveFacet;
    data['opds:facetGroup'] = opdsFacetGroup;
    data['thr:count'] = thrCount;
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksLink(rel: $rel, type: $type, href: $href, title: $title, opdsActiveFacet: $opdsActiveFacet, opdsFacetGroup: $opdsFacetGroup, thrCount: $thrCount)';
  }
}
