import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `consumption` on a 开眼 feed item (`common_item_model.dart:571`).
///
/// The detail screen renders all three counters (`video_detail_page.dart:142-198`).
class EyepetizerConsumption {
  const EyepetizerConsumption({
    this.shareCount = 0,
    this.replyCount = 0,
    this.collectionCount = 0,
  });

  factory EyepetizerConsumption.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerConsumption(
      shareCount: EyepetizerJson.asInt(map['shareCount']),
      replyCount: EyepetizerJson.asInt(map['replyCount']),
      collectionCount: EyepetizerJson.asInt(map['collectionCount']),
    );
  }

  final int shareCount;
  final int replyCount;
  final int collectionCount;
}
