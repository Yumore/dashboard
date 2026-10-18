import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_entry.dart';

/// One dated group of the update feed.
///
/// `comicUpdateDate` and `comicUpdateDate_new` keep their camelCase JSON keys —
/// the backend does not snake_case them.
///
/// Source: `lib/models/update_list.dart` → `Update`.
class ManhuataiUpdateGroup {
  const ManhuataiUpdateGroup({
    required this.comicUpdateDate,
    required this.comicUpdateDateNew,
    required this.info,
  });

  final String comicUpdateDate;
  final String comicUpdateDateNew;
  final List<ManhuataiUpdateEntry> info;

  factory ManhuataiUpdateGroup.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiUpdateGroup(
      comicUpdateDate: ManhuataiJson.asString(source['comicUpdateDate']),
      comicUpdateDateNew: ManhuataiJson.asString(source['comicUpdateDate_new']),
      info: ManhuataiJson.maps(source['info'])
          .map(ManhuataiUpdateEntry.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comicUpdateDate': comicUpdateDate,
        'comicUpdateDate_new': comicUpdateDateNew,
        'info': info.map((item) => item.toJson()).toList(),
      };
}
