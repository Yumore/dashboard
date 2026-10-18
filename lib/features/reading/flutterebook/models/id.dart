/// GData text node (`{"$t": "..."}`) as produced by the Feedbooks atom feeds.
///
/// Feedbooks encodes every leaf element (id, title, updated, summary, ...) as a
/// map carrying its text under the `$t` key, so a single [FeedbooksId] type is reused for
/// all of them.
class FeedbooksId {
  FeedbooksId({this.t});

  FeedbooksId.fromJson(Map<String, dynamic> json) {
    t = json[r'$t'] as String?;
  }

  String? t;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[r'$t'] = t;
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksId(t: $t)';
  }
}
