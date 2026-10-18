/// A user of the forum: name plus user page url.
///
/// Ported from `tsdm_client/lib/shared/models/user.dart`.
class TsdmUser {
  const TsdmUser({
    required this.name,
    required this.url,
    this.uid,
    this.avatarUrl,
  });

  /// User name.
  final String name;

  /// User homepage url.
  final String url;

  /// User id.
  ///
  /// Not always available, so not required.
  final String? uid;

  /// User avatar url, may be null.
  final String? avatarUrl;

  /// Whether this user has both a name and an url.
  bool isValid() => name.isNotEmpty && url.isNotEmpty;

  /// Whether this user misses a name or an url.
  bool isNotValid() => !isValid();

  @override
  String toString() => 'TsdmUser(name: $name, uid: $uid, url: $url)';
}
