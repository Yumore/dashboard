import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_header.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `PersonRepository.getPersonHomePageData`'s in-line post-processing,
/// extracted so it is testable without a transport.
///
/// The source re-encoded the page (`jsonDecode(jsonEncode(result['itemList']))`)
/// purely to force plain maps, then, for each
/// `videoCollectionOfHorizontalScrollCard`, rebuilt a flat
/// [EyepetizerFlutterItemBanner] list out of the card's nested items and wrote
/// it onto **`baseListData.itemList[0].data.itemList`** — always index `0`,
/// even when the collection card sits elsewhere, and with one accumulator
/// shared by every collection card on the page. Both quirks are preserved
/// because the person-home view reads exactly that list.
class EyepetizerFlutterPersonHomeParser {
  const EyepetizerFlutterPersonHomeParser._();

  /// The one item type this pass rewrites.
  static const String collectionCardType =
      'videoCollectionOfHorizontalScrollCard';

  static EyepetizerFlutterBaseListData parse(Map<String, dynamic> result) {
    final baseListData = EyepetizerFlutterBaseListData.fromJson(result);
    final rawItems = result['itemList'];
    if (rawItems is! List) return baseListData;

    final banners = <EyepetizerFlutterItemBanner>[];
    for (final raw in rawItems) {
      final map = EyepetizerFlutterJson.asMapOrNull(raw);
      if (map == null) continue;
      if (EyepetizerFlutterJson.asString(map['type']) != collectionCardType) {
        continue;
      }
      // The source read the *outer* card's header and attached it to every
      // rebuilt banner, not the nested item's own header.
      final header = EyepetizerFlutterHeader.fromJson(
        EyepetizerFlutterJson.asMap(map['header']),
      );
      final listData = EyepetizerFlutterBaseListData.fromJson(
        EyepetizerFlutterJson.asMap(map['data']),
      );
      for (final element in listData.itemList) {
        final entity = _bannerDataOf(element);
        if (entity == null) continue;
        banners.add(
          EyepetizerFlutterItemBanner(
            type: element.type,
            header: header,
            data: entity,
          ),
        );
      }
      final target = baseListData.itemList.isEmpty
          ? null
          : baseListData.itemList.first.data;
      if (target != null) target.itemList = banners;
    }
    return baseListData;
  }

  /// The source built this object positionally from `element.data.*`, so every
  /// field below maps to one argument of that constructor call:
  /// `dataType, id, header.title, "", header.description,
  ///  content.data.cover.feed, actionUrl, null(label), header, header.icon, ""`.
  static EyepetizerFlutterItemBannerData? _bannerDataOf(
    EyepetizerFlutterItem element,
  ) {
    final data = element.data;
    if (data == null) return null;
    final header = data.header;
    final cover = data.content?.data?.cover;
    return EyepetizerFlutterItemBannerData(
      dataType: data.dataType,
      id: data.id,
      title: header?.title,
      subTitle: '',
      description: header?.description,
      image: cover?.feed,
      actionUrl: data.actionUrl,
      label: null,
      header: header,
      icon: header?.icon,
      bgPicture: '',
    );
  }
}
