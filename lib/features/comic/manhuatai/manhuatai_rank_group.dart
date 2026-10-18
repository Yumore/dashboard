import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_comic.dart';

/// One ranking group of `getIndexRankData`.
///
/// Source: `lib/models/rank_list.dart` → `Data`.
class ManhuataiRankGroup {
  const ManhuataiRankGroup({
    required this.type,
    required this.name,
    required this.list,
  });

  final String type;
  final String name;
  final List<ManhuataiRankComic> list;

  factory ManhuataiRankGroup.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankGroup(
      type: ManhuataiJson.asString(source['type']),
      name: ManhuataiJson.asString(source['name']),
      list: ManhuataiJson.maps(source['list'])
          .map(ManhuataiRankComic.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'name': name,
        'list': list.map((item) => item.toJson()).toList(),
      };
}
