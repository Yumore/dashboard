import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_images.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// A cast/director entry as embedded in subject and work payloads.
///
/// Real douban payloads leave `id`, `alt` and `avatars` null for minor
/// participants (see `mock/works.json`), so every field tolerates null.
class FlutterDouBanCelebritySummary {
  const FlutterDouBanCelebritySummary({
    this.id = '',
    this.name = '',
    this.nameEn = '',
    this.alt = '',
    this.avatars = const FlutterDouBanImages(),
  });

  factory FlutterDouBanCelebritySummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FlutterDouBanCelebritySummary();
    return FlutterDouBanCelebritySummary(
      id: FlutterDouBanJson.asString(json['id']).trim(),
      name: FlutterDouBanJson.asString(json['name']).trim(),
      nameEn: FlutterDouBanJson.asString(json['name_en']).trim(),
      alt: FlutterDouBanJson.asString(json['alt']).trim(),
      avatars: FlutterDouBanImages.fromJson(
        FlutterDouBanJson.asMapOrNull(json['avatars']),
      ),
    );
  }

  static List<FlutterDouBanCelebritySummary> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanCelebritySummary.fromJson).toList(growable: false);

  final String id;
  final String name;
  final String nameEn;
  final String alt;
  final FlutterDouBanImages avatars;

  bool get hasId => id.isNotEmpty;

  String? get avatarUrl => FlutterDouBanImage.resolve(avatars.preferred);

  /// `中文名 / English Name`, falling back to whichever side exists.
  String get displayName {
    if (name.isNotEmpty && nameEn.isNotEmpty) return '$name / $nameEn';
    return name.isNotEmpty ? name : nameEn;
  }
}
