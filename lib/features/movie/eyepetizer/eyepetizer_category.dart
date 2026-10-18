import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// One row of `v4/categories` (`module_discover/lib/model/category_model.dart:6`).
class EyepetizerCategory {
  const EyepetizerCategory({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.bgPicture = '',
    this.bgColor = '',
    this.headerImage = '',
    this.defaultAuthorId = 0,
    this.tagId = 0,
    this.alias = '',
  });

  factory EyepetizerCategory.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerCategory(
      id: EyepetizerJson.asInt(map['id']),
      name: EyepetizerJson.asString(map['name']),
      description: EyepetizerJson.asString(map['description']),
      bgPicture: EyepetizerJson.asString(map['bgPicture']),
      bgColor: EyepetizerJson.asString(map['bgColor']),
      headerImage: EyepetizerJson.asString(map['headerImage']),
      defaultAuthorId: EyepetizerJson.asInt(map['defaultAuthorId']),
      tagId: EyepetizerJson.asInt(map['tagId']),
      alias: EyepetizerJson.asString(map['alias']),
    );
  }

  final int id;
  final String name;
  final String description;
  final String bgPicture;
  final String bgColor;
  final String headerImage;
  final int defaultAuthorId;
  final int tagId;

  /// The source's category grid printed this instead of [name]
  /// (`category_page.dart:66`).
  final String alias;
}
