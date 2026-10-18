import '../pixez_json.dart';

/// The three thumbnail sizes pixiv returns for an illust/novel cover.
class PixezImageUrls {
  const PixezImageUrls({
    required this.squareMedium,
    required this.medium,
    required this.large,
  });

  final String squareMedium;
  final String medium;
  final String large;

  factory PixezImageUrls.fromJson(Map<String, dynamic> json) {
    return PixezImageUrls(
      squareMedium: pixezString(json['square_medium']),
      medium: pixezString(json['medium']),
      large: pixezString(json['large']),
    );
  }
}
