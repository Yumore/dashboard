/// Image quality sent as the `image-quality` request header.
///
/// The wire value is the enum `name`; `displayName` is the upstream label
/// (`haka_comic/lib/network/utils.dart:11-27`).
enum HakaImageQuality {
  low('低'),
  medium('中'),
  high('高'),
  original('原画');

  const HakaImageQuality(this.displayName);

  final String displayName;

  static HakaImageQuality fromName(String? name) {
    return HakaImageQuality.values.firstWhere(
      (quality) => quality.name == name,
      orElse: () => HakaImageQuality.original,
    );
  }
}
