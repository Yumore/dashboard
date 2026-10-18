import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_group.dart';

/// Response of `updatelist` — the "recently updated" home tab.
///
/// Source: `lib/models/update_list.dart` → `UpdateList`.
class ManhuataiUpdateList {
  const ManhuataiUpdateList({
    required this.tabTitle,
    required this.update,
    required this.today,
    required this.servicetime,
  });

  final String tabTitle;
  final List<ManhuataiUpdateGroup> update;
  final List<ManhuataiUpdateGroup> today;
  final int servicetime;

  static const ManhuataiUpdateList empty = ManhuataiUpdateList(
    tabTitle: '',
    update: <ManhuataiUpdateGroup>[],
    today: <ManhuataiUpdateGroup>[],
    servicetime: 0,
  );

  factory ManhuataiUpdateList.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiUpdateList(
      tabTitle: ManhuataiJson.asString(source['tab_title']),
      update: ManhuataiJson.maps(source['update'])
          .map(ManhuataiUpdateGroup.fromJson)
          .toList(),
      today: ManhuataiJson.maps(source['today'])
          .map(ManhuataiUpdateGroup.fromJson)
          .toList(),
      servicetime: ManhuataiJson.asInt(source['servicetime']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tab_title': tabTitle,
        'update': update.map((item) => item.toJson()).toList(),
        'today': today.map((item) => item.toJson()).toList(),
        'servicetime': servicetime,
      };
}
