/// Hosts serving the picacomic API schema.
///
/// Upstream (`haka_comic/lib/network/utils.dart:29-43`) shipped two hosts and
/// defaulted to the community relay `go2778`
/// (`haka_comic/lib/config/app_config.dart:63`).
///
/// This port keeps both hosts selectable but defaults to the public picacomic
/// endpoint instead of the operator relay.
enum HakaApi {
  picacomic('https://picaapi.picacomic.com/'),
  go2778('https://picaapi.go2778.com/');

  const HakaApi(this.host);

  /// Base URL including the trailing slash.
  final String host;

  static HakaApi fromName(String? name) {
    return HakaApi.values.firstWhere(
      (api) => api.name == name,
      orElse: () => HakaApi.picacomic,
    );
  }
}
