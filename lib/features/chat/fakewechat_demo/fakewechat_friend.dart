/// Port of `Friend` from the source `lib/entities.dart`.
///
/// The source relies on const identity (`sender == USER`) instead of equality,
/// so this class deliberately does not override `==`.
class FakeWechatFriend {
  const FakeWechatFriend({required this.name, this.avatar, this.momentsCover});

  final String name;

  /// Source avatar URL. The source app has no bundled UI images; the port keeps
  /// the URL as data but never loads it (the demo is offline).
  final String? avatar;

  /// Source moments-cover URL. Kept for fidelity, never loaded.
  final String? momentsCover;
}
