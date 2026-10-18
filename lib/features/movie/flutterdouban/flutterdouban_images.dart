import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// Douban's `images` object: `{small, medium, large}`.
class FlutterDouBanImages {
  const FlutterDouBanImages({
    this.small = '',
    this.medium = '',
    this.large = '',
  });

  factory FlutterDouBanImages.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FlutterDouBanImages();
    return FlutterDouBanImages(
      small: FlutterDouBanJson.asString(json['small']).trim(),
      medium: FlutterDouBanJson.asString(json['medium']).trim(),
      large: FlutterDouBanJson.asString(json['large']).trim(),
    );
  }

  final String small;
  final String medium;
  final String large;

  bool get isEmpty => small.isEmpty && medium.isEmpty && large.isEmpty;

  /// Dulwich payloads sometimes only fill one size; prefer the largest.
  String get preferred {
    if (large.isNotEmpty) return large;
    if (medium.isNotEmpty) return medium;
    return small;
  }

  String? get preferredUrl => FlutterDouBanImage.resolve(preferred);
}
