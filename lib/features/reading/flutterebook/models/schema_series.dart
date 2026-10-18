/// `<schema:Series>` of a Feedbooks book entry. Holds the series position, name
/// and url of a book that belongs to a series.
///
/// NOTE (ported verbatim from the source model): the source reads the keys
/// `schema:position` / `schema:name` / `schema:url` with a colon, while the
/// GData transform renames element names to `schema$position` / `schema$name` /
/// `schema$url`. On a real Feedbooks feed these three fields therefore stay
/// `null`; the behaviour is preserved (and pinned by a test) instead of being
/// silently "fixed", so the port does not diverge from the source app.
class FeedbooksSchemaSeries {
  FeedbooksSchemaSeries({this.schemaPosition, this.schemaName, this.schemaUrl});

  FeedbooksSchemaSeries.fromJson(Map<String, dynamic> json) {
    schemaPosition = json['schema:position'] as String?;
    schemaName = json['schema:name'] as String?;
    schemaUrl = json['schema:url'] as String?;
  }

  String? schemaPosition;
  String? schemaName;
  String? schemaUrl;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schema:position'] = schemaPosition;
    data['schema:name'] = schemaName;
    data['schema:url'] = schemaUrl;
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksSchemaSeries(schemaPosition: $schemaPosition, schemaName: $schemaName, schemaUrl: $schemaUrl)';
  }
}
