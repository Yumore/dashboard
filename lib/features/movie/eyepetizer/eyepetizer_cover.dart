import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `cover` on a 开眼 feed item (`module_common/lib/model/common_item_model.dart:252`).
class EyepetizerCover {
  const EyepetizerCover({
    this.feed = '',
    this.detail = '',
    this.blurred = '',
    this.homepage = '',
  });

  factory EyepetizerCover.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerCover(
      feed: EyepetizerJson.asString(map['feed']),
      detail: EyepetizerJson.asString(map['detail']),
      blurred: EyepetizerJson.asString(map['blurred']),
      homepage: EyepetizerJson.asString(map['homepage']),
    );
  }

  /// 16:9 banner / list thumbnail.
  final String feed;

  /// Larger still used by the detail page and the "related" rows.
  final String detail;

  final String blurred;
  final String homepage;
}
