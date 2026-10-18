/// 禁漫天堂 image CDN hosts, ported from
/// PicaComic lib/network/jm_network/jm_image.dart.
///
/// PicaComic selected the host from `appdata.settings[37]`; the host module has
/// no settings store for this port, so [defaultBaseUrl] (index 0) is used and
/// every helper accepts an explicit base.
class JmImageUrls {
  JmImageUrls._();

  static const List<String> hosts = [
    'https://cdn-msp.jmapiproxy3.cc',
    'https://cdn-msp3.jmapiproxy3.cc',
    'https://cdn-msp2.jmapiproxy1.cc',
    'https://cdn-msp3.jmapiproxy3.cc',
    'https://cdn-msp2.jmapiproxy4.cc',
    'https://cdn-msp2.jmapiproxy3.cc',
  ];

  static const String defaultBaseUrl = 'https://cdn-msp.jmapiproxy3.cc';

  static String hostAt(int index) =>
      hosts[index.clamp(0, hosts.length - 1).toInt()];

  /// `/media/albums/<id>_3x4.jpg`
  static String cover(String id, [String base = defaultBaseUrl]) =>
      '$base/media/albums/${id}_3x4.jpg';

  /// `/media/photos/<id>/<imageName>`
  static String photo(String imageName, String id,
          [String base = defaultBaseUrl]) =>
      '$base/media/photos/$id/$imageName';

  /// `/media/users/<imageName>`
  static String avatar(String imageName, [String base = defaultBaseUrl]) =>
      '$base/media/users/$imageName';
}
