/// Port of `MinProgram` from the source `lib/data_source.dart`.
///
/// The source stores a navigation callback into the TikTok/Douban/Reader
/// modules. Those modules are not part of this port, so [unavailableNote]
/// carries the explicit, honest outcome instead of a dead callback.
class FakeWechatMinProgram {
  const FakeWechatMinProgram({
    required this.name,
    required this.icon,
    this.unavailableNote,
  });

  final String name;

  /// Source remote icon URL. Never loaded by the offline demo.
  final String icon;

  final String? unavailableNote;
}
