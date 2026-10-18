import 'package:dashboard/features/movie/eyepetizer/eyepetizer_data.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// One entry of `itemList` (`common_item_model.dart:17`).
///
/// The source switched on [type] in every list body, which is why the item
/// types are declared here as constants rather than scattered string literals.
class EyepetizerItem {
  const EyepetizerItem({
    this.data,
    this.adIndex = 0,
    this.id = 0,
    this.type = '',
  });

  /// The stand-in the source inserted at index 0 of the home list so the banner
  /// carousel could live inside the same `ListView`
  /// (`module_home/lib/viewmodel/home_page_model.dart`, `doRefreshDataProcess`).
  const EyepetizerItem.placeholder()
    : data = null,
      adIndex = 0,
      id = 0,
      type = placeholderType;

  factory EyepetizerItem.fromJson(Object? json) {
    if (json is num || json is String) {
      // Some legacy rows are bare ids; keep them addressable instead of throwing.
      return EyepetizerItem(id: EyepetizerJson.asInt(json));
    }
    final map = EyepetizerJson.asMap(json);
    return EyepetizerItem(
      data: map['data'] == null ? null : EyepetizerData.fromJson(map['data']),
      adIndex: EyepetizerJson.asInt(map['adIndex']),
      id: EyepetizerJson.asInt(map['id']),
      type: EyepetizerJson.asString(map['type']),
    );
  }

  /// `banner2` — the home page pulls these out of the first issue into the
  /// carousel (`home_page.dart`, `doLoadMoreDataProcess`).
  static const String bannerType = 'banner2';

  /// `textHeader` — a section title row.
  static const String textHeaderType = 'textHeader';

  /// `videoSmallCard` — the row used by search results and video detail.
  static const String videoSmallCardType = 'videoSmallCard';

  /// Synthetic type of [EyepetizerItem.placeholder].
  static const String placeholderType = 'placeholder';

  final EyepetizerData? data;
  final int adIndex;
  final int id;
  final String type;

  bool get isPlaceholder => type == placeholderType;

  bool get isTextHeader => type == textHeaderType;

  bool get isBanner => type == bannerType;

  /// The section title of a [textHeaderType] row, else empty.
  String get headerText => isTextHeader ? (data?.text ?? '') : '';
}
