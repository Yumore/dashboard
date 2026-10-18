import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/consumption.dart`.
class EyepetizerFlutterConsumption {
  const EyepetizerFlutterConsumption({
    this.collectionCount,
    this.shareCount,
    this.replyCount,
    this.realCollectionCount,
  });

  factory EyepetizerFlutterConsumption.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterConsumption(
        collectionCount: EyepetizerFlutterJson.asNullableInt(
          json['collectionCount'],
        ),
        shareCount: EyepetizerFlutterJson.asNullableInt(json['shareCount']),
        replyCount: EyepetizerFlutterJson.asNullableInt(json['replyCount']),
        realCollectionCount: EyepetizerFlutterJson.asNullableInt(
          json['realCollectionCount'],
        ),
      );

  final int? collectionCount;
  final int? shareCount;
  final int? replyCount;
  final int? realCollectionCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'collectionCount': collectionCount,
    'shareCount': shareCount,
    'replyCount': replyCount,
    'realCollectionCount': realCollectionCount,
  };
}
