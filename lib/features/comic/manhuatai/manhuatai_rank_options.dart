import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_product_option.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_option.dart';

/// Options payload of `getRankTypes`.
///
/// Source: `lib/models/rank_types.dart` → `Data`.
class ManhuataiRankOptions {
  const ManhuataiRankOptions({
    required this.rankTypeList,
    required this.sortTypeList,
    required this.productIdList,
    required this.timeTypeList,
    required this.yearlist,
    required this.servertime,
    required this.weeklist,
  });

  final List<ManhuataiRankOption> rankTypeList;
  final List<ManhuataiRankOption> sortTypeList;
  final List<ManhuataiProductOption> productIdList;
  final List<ManhuataiRankOption> timeTypeList;
  final List<int> yearlist;
  final int servertime;
  final List<dynamic> weeklist;

  static const ManhuataiRankOptions empty = ManhuataiRankOptions(
    rankTypeList: <ManhuataiRankOption>[],
    sortTypeList: <ManhuataiRankOption>[],
    productIdList: <ManhuataiProductOption>[],
    timeTypeList: <ManhuataiRankOption>[],
    yearlist: <int>[],
    servertime: 0,
    weeklist: <dynamic>[],
  );

  static List<ManhuataiRankOption> _options(dynamic value) {
    return ManhuataiJson.maps(value)
        .map(
          (item) => ManhuataiRankOption(
            name: ManhuataiJson.asString(item['name']),
            value: ManhuataiJson.asString(item['value']),
          ),
        )
        .toList();
  }

  factory ManhuataiRankOptions.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankOptions(
      rankTypeList: _options(source['rank_type_list']),
      sortTypeList: _options(source['sort_type_list']),
      productIdList: ManhuataiJson.maps(source['product_id_list'])
          .map(ManhuataiProductOption.fromJson)
          .toList(),
      timeTypeList: _options(source['time_type_list']),
      yearlist: ManhuataiJson.asIntList(source['yearlist']),
      servertime: ManhuataiJson.asInt(source['servertime']),
      weeklist: source['weeklist'] is List
          ? source['weeklist'] as List<dynamic>
          : <dynamic>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'rank_type_list': rankTypeList
            .map((item) => <String, dynamic>{'name': item.name, 'value': item.value})
            .toList(),
        'sort_type_list': sortTypeList
            .map((item) => <String, dynamic>{'name': item.name, 'value': item.value})
            .toList(),
        'product_id_list': productIdList
            .map((item) => <String, dynamic>{'name': item.name, 'value': item.value})
            .toList(),
        'time_type_list': timeTypeList
            .map((item) => <String, dynamic>{'name': item.name, 'value': item.value})
            .toList(),
        'yearlist': yearlist,
        'servertime': servertime,
        'weeklist': weeklist,
      };
}
