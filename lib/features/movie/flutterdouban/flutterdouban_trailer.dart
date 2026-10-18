import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// A `trailers` / `bloopers` / `clips` entry on a subject detail payload.
class FlutterDouBanTrailer {
  const FlutterDouBanTrailer({
    this.id = '',
    this.subjectId = '',
    this.title = '',
    this.alt = '',
    this.small = '',
    this.medium = '',
    this.resourceUrl = '',
  });

  factory FlutterDouBanTrailer.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanTrailer(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        subjectId: FlutterDouBanJson.asString(json['subject_id']).trim(),
        title: FlutterDouBanJson.asString(json['title']).trim(),
        alt: FlutterDouBanJson.asString(json['alt']).trim(),
        small: FlutterDouBanJson.asString(json['small']).trim(),
        medium: FlutterDouBanJson.asString(json['medium']).trim(),
        resourceUrl: FlutterDouBanJson.asString(json['resource_url']).trim(),
      );

  static List<FlutterDouBanTrailer> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanTrailer.fromJson).toList(growable: false);

  final String id;
  final String subjectId;
  final String title;
  final String alt;
  final String small;
  final String medium;
  final String resourceUrl;

  String? get imageUrl =>
      FlutterDouBanImage.resolve(medium.isNotEmpty ? medium : small);
}
