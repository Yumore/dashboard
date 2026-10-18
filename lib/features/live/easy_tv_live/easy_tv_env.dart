/// Endpoints and mirror handling ported from the source app's `EnvUtil`.
///
/// The source app probes these public mirrors of the same GitHub playlist; the
/// mirror is prepended to the raw GitHub URL as those proxies expect. Nothing
/// here talks to a private backend.
class EasyTvEnv {
  const EasyTvEnv({this.proxyIndex = defaultProxyIndex});

  /// The source app defaults `dataValueProxy` to `1`, i.e. the first mirror.
  static const defaultProxyIndex = 1;

  static const proxyPrefixes = <String>[
    '',
    'https://easytv.suntengfei.top/',
    'http://ghp.keleyaa.com/',
  ];

  /// Public default playlist shipped by the source project.
  static const defaultPlaylistUrl =
      'https://raw.githubusercontent.com/aiyakuaile/easy_tv_live/main/temp';

  static const sourceLinkKey = 'default';

  final int proxyIndex;

  String get playlistUrl => playlistUrlFor(proxyIndex);

  String playlistUrlFor(int index) {
    final safe = index >= 0 && index < proxyPrefixes.length ? index : 0;
    return '${proxyPrefixes[safe]}$defaultPlaylistUrl';
  }

  /// Expands the `default` pseudo-link into the configured public playlist URL.
  String resolve(String link) => link == sourceLinkKey ? playlistUrl : link;
}
