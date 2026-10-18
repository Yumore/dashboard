/// Port of `Marker` from the source `lib/entities.dart`.
///
/// The seeded chat detail page inserts a type-0 marker before every outgoing
/// text message; the marker text is `DateTime.now().toString()`.
class FakeWechatMarker {
  const FakeWechatMarker(this.type, this.text);

  static const int timeType = 0;

  final int type;
  final String text;
}
