import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Layout description of a home-page section.
///
/// `display_type` drives which cover layout the source picked: 6/8 → grid,
/// 9/29 → horizontal strip, 3/0/11 → four-or-six cover row, 61/72 → special
/// rows, anything else → fallback layout 1.
///
/// Source: `lib/models/book_list.dart` → `Config`.
class ManhuataiBookConfig {
  const ManhuataiBookConfig({
    required this.displayType,
    required this.isAutoSlide,
    required this.isShowTitle,
    required this.horizonratio,
    required this.interwidth,
    required this.outerwidth,
    required this.orderType,
    required this.isShowChange,
    required this.isShowDetail,
    required this.isShowMore,
  });

  final int displayType;
  final int isAutoSlide;
  final int isShowTitle;

  /// Aspect ratio string such as `3:4` or `16:9`.
  final String horizonratio;

  /// `dynamic` in the source: sometimes numeric, sometimes a width string.
  final String interwidth;
  final String outerwidth;
  final int orderType;
  final int isShowChange;

  /// A `0`/`1` int on the feed but a boolean on other CMS responses.
  final bool isShowDetail;
  final int isShowMore;

  static const ManhuataiBookConfig empty = ManhuataiBookConfig(
    displayType: 0,
    isAutoSlide: 0,
    isShowTitle: 0,
    horizonratio: '3:4',
    interwidth: '',
    outerwidth: '',
    orderType: 0,
    isShowChange: 0,
    isShowDetail: false,
    isShowMore: 0,
  );

  /// Number of covers a `display_type` renders in one row.
  int get coversPerRow {
    if (displayType == 11) return 6;
    if (displayType == 3 || displayType == 0) return 4;
    return 4;
  }

  factory ManhuataiBookConfig.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBookConfig(
      displayType: ManhuataiJson.asInt(source['display_type']),
      isAutoSlide: ManhuataiJson.asInt(source['isautoslide']),
      isShowTitle: ManhuataiJson.asInt(source['isshowtitle']),
      horizonratio: ManhuataiJson.asString(
        source['horizonratio'],
        fallback: '3:4',
      ),
      interwidth: ManhuataiJson.asDynamicString(source['interwidth']),
      outerwidth: ManhuataiJson.asDynamicString(source['outerwidth']),
      orderType: ManhuataiJson.asInt(source['order_type']),
      isShowChange: ManhuataiJson.asInt(source['isshowchange']),
      isShowDetail: ManhuataiJson.asBool(source['isshowdetail']),
      isShowMore: ManhuataiJson.asInt(source['isshowmore']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'display_type': displayType,
        'isautoslide': isAutoSlide,
        'isshowtitle': isShowTitle,
        'horizonratio': horizonratio,
        'interwidth': interwidth,
        'outerwidth': outerwidth,
        'order_type': orderType,
        'isshowchange': isShowChange,
        'isshowdetail': isShowDetail,
        'isshowmore': isShowMore,
      };
}
