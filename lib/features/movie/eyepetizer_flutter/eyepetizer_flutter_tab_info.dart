import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_tab_data.dart';

/// `lib/model/person_mainpage.dart` → `TabInfo`.
///
/// The source read `json['tabList'] as List` with no null guard, so a person
/// payload without tabs threw. The port degrades that to an empty list; the
/// page then renders a gallery with zero tabs instead of a crash.
class EyepetizerFlutterTabInfo {
  const EyepetizerFlutterTabInfo({
    this.tabList = const <EyepetizerFlutterTabData>[],
    this.defaultIdx,
  });

  factory EyepetizerFlutterTabInfo.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterTabInfo(
        tabList: EyepetizerFlutterJson.asMapList(
          json['tabList'],
        ).map(EyepetizerFlutterTabData.fromJson).toList(growable: false),
        defaultIdx: EyepetizerFlutterJson.asNullableInt(json['defaultIdx']),
      );

  final List<EyepetizerFlutterTabData> tabList;
  final int? defaultIdx;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tabList': tabList.map((tab) => tab.toJson()).toList(),
    'defaultIdx': defaultIdx,
  };
}
