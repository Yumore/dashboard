import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';

/// 首页一次加载出来的内容：幻灯片 + 父类 + 每个父类的推荐网格。
class FlutterMoviesHomeData {
  const FlutterMoviesHomeData({
    this.sliders = const <FlutterMoviesListItem>[],
    this.updates = const <FlutterMoviesListItem>[],
    this.parents = const <FlutterMoviesCategory>[],
    this.grids = const <int, List<FlutterMoviesListItem>>{},
  });

  final List<FlutterMoviesListItem> sliders;

  /// 最近更新（`h=24` 小时内的数据）。
  final List<FlutterMoviesListItem> updates;
  final List<FlutterMoviesCategory> parents;
  final Map<int, List<FlutterMoviesListItem>> grids;

  bool get isEmpty =>
      sliders.isEmpty &&
      updates.isEmpty &&
      grids.values.every((items) => items.isEmpty);

  List<FlutterMoviesListItem> gridOf(int parentTypeId) =>
      grids[parentTypeId] ?? const <FlutterMoviesListItem>[];
}
