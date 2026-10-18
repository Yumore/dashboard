import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_header.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_label.dart';

/// `lib/model/item_banner.dart` → `ItemBannerDataEntity`.
///
/// The `image` fallback (`json['image'] == null ? json['bgPicture'] : ...`) is
/// the one the 开眼 home page relies on for banner tiles, and it survives the
/// local-cache JSON round trip.
class EyepetizerFlutterItemBannerData {
  const EyepetizerFlutterItemBannerData({
    this.dataType,
    this.id,
    this.title,
    this.subTitle,
    this.description,
    this.image,
    this.actionUrl,
    this.label,
    this.header,
    this.icon,
    this.bgPicture,
  });

  factory EyepetizerFlutterItemBannerData.fromJson(Map<String, dynamic> json) {
    return EyepetizerFlutterItemBannerData(
      dataType: EyepetizerFlutterJson.asNullableString(json['dataType']),
      id: EyepetizerFlutterJson.asNullableInt(json['id']),
      title: EyepetizerFlutterJson.asNullableString(json['title']),
      subTitle: EyepetizerFlutterJson.asNullableString(json['subTitle']),
      description: EyepetizerFlutterJson.asNullableString(json['description']),
      image: json['image'] == null
          ? EyepetizerFlutterJson.asNullableString(json['bgPicture'])
          : EyepetizerFlutterJson.asNullableString(json['image']),
      actionUrl: EyepetizerFlutterJson.asNullableString(json['actionUrl']),
      label: json['label'] is Map
          ? EyepetizerFlutterLabel.fromJson(
              EyepetizerFlutterJson.asMap(json['label']),
            )
          : null,
      header: json['header'] is Map
          ? EyepetizerFlutterHeader.fromJson(
              EyepetizerFlutterJson.asMap(json['header']),
            )
          : null,
      icon: EyepetizerFlutterJson.asNullableString(json['icon']),
      bgPicture: EyepetizerFlutterJson.asNullableString(json['bgPicture']),
    );
  }

  final String? dataType;
  final int? id;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? image;
  final String? actionUrl;
  final EyepetizerFlutterLabel? label;
  final EyepetizerFlutterHeader? header;
  final String? icon;
  final String? bgPicture;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'dataType': dataType,
    'id': id,
    'title': title,
    'subTitle': subTitle,
    'description': description,
    'image': image,
    'actionUrl': actionUrl,
    'label': label?.toJson(),
    'header': header?.toJson(),
    'icon': icon,
    'bgPicture': bgPicture,
  };
}
