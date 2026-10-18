import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_kind.dart';

/// A loaded value plus where it came from.
///
/// Keeping the provenance on the payload (instead of only in the widget that
/// issued the request) is what lets the port show `网络 · api.douban.com` vs
/// `本地 Mock · mock/in_theaters.json` for every individual list.
class FlutterDouBanData<T> {
  const FlutterDouBanData({
    required this.value,
    required this.kind,
    required this.origin,
    this.assetPath,
  });

  final T value;
  final FlutterDouBanSourceKind kind;
  final String origin;

  /// The bundled fixture path when [kind] is [FlutterDouBanSourceKind.mock].
  final String? assetPath;

  bool get mocked => kind == FlutterDouBanSourceKind.mock;

  /// Short human label, e.g. `网络 · api.douban.com`.
  String get label => '${kind.label} · $origin';
}
