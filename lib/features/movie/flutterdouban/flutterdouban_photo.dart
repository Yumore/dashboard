import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// A celebrity gallery entry: `{thumb, image, cover, alt, id, icon}`.
class FlutterDouBanPhoto {
  const FlutterDouBanPhoto({
    this.id = '',
    this.alt = '',
    this.thumb = '',
    this.image = '',
    this.cover = '',
    this.icon = '',
  });

  factory FlutterDouBanPhoto.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanPhoto(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        alt: FlutterDouBanJson.asString(json['alt']).trim(),
        thumb: FlutterDouBanJson.asString(json['thumb']).trim(),
        image: FlutterDouBanJson.asString(json['image']).trim(),
        cover: FlutterDouBanJson.asString(json['cover']).trim(),
        icon: FlutterDouBanJson.asString(json['icon']).trim(),
      );

  static List<FlutterDouBanPhoto> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanPhoto.fromJson).toList(growable: false);

  final String id;
  final String alt;
  final String thumb;
  final String image;
  final String cover;
  final String icon;

  String get preferred =>
      image.isNotEmpty ? image : (thumb.isNotEmpty ? thumb : cover);

  String? get url => FlutterDouBanImage.resolve(preferred);
}
