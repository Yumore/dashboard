/// Type of a thread, `宣传`, `心情`, `其他`...
///
/// Ported from `tsdm_client/lib/shared/models/thread_type.dart`.
class TsdmThreadType {
  const TsdmThreadType({required this.name, required this.url});

  /// Display name.
  final String name;

  /// Url.
  final String url;

  /// Build a [TsdmThreadType], null when [name] or [url] is missing.
  static TsdmThreadType? parse(String? name, String? url) {
    if (name != null && url != null) {
      return TsdmThreadType(name: name, url: url);
    }
    return null;
  }
}
