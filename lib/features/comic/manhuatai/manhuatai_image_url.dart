import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';

/// CDN hosts and cover/page URL rules of the manhuatai network.
///
/// Ported from `lib/common/const/app_const.dart` (hosts + `imageSizeSuffixMap`)
/// and the two URL builders in `lib/utils/utils.dart`
/// (`formatBookImgUrl`, `generateImgUrlFromId`).
///
/// The source chose the suffix set with `Platform.isIOS`; that makes URL
/// building depend on the runtime platform and is untestable off-device. This
/// port keeps both sets as data and defaults to the Android/WebP set, which is
/// what the source used on the platform this app ships to.
class ManhuataiImageUrl {
  const ManhuataiImageUrl._();

  static const String imgHost = 'https://image.mhxk.com';
  static const String imageHost = 'http://image.yqmh.com';
  static const String mhHost = 'http://mhpic.jumanhua.com';
  static const String cmsHost = 'http://cms.samanlehua.com';
  static const String headImgHost = 'http://head.samanlehua.com';

  /// Android/WebP variants (source default on Android and on web builds).
  static const Map<String, String> webpSuffixMap = <String, String>{
    'h1x1': '-600x600.jpg.webp',
    'm1x1': '-480x480.jpg.webp',
    'l1x1': '-300x300.jpg.webp',
    'h3x4': '-600x800.jpg.webp',
    'm3x4': '-960x1280.jpg.webp',
    'l3x4': '-300x400.jpg.webp',
    'h4x3': '-800x600.jpg.webp',
    'm4x3': '-640x480.jpg.webp',
    'l4x3': '-400x300.jpg.webp',
    'h16x7': '-800x350.jpg.webp',
    'm16x7': '-640x280.jpg.webp',
    'l16x7': '-400x175.jpg.webp',
    'h2x1': '-800x400.jpg.webp',
    'm2x1': '-640x320.jpg.webp',
    'l2x1': '-400x200.jpg.webp',
    'h16x9': '-800x450.jpg.webp',
    'm16x9': '-640x360.jpg.webp',
    'l16x9': '-400x225.jpg.webp',
    'head': '-100x100.webp',
    'default': '-noresize.webp',
  };

  /// iOS/JPG variants (`Platform.isIOS == true` in the source).
  static const Map<String, String> jpgSuffixMap = <String, String>{
    'h1x1': '-600x600.jpg',
    'm1x1': '-480x480.jpg',
    'l1x1': '-300x300.jpg',
    'h3x4': '-600x800.jpg',
    'm3x4': '-480x640.jpg',
    'l3x4': '-300x400.jpg',
    'h4x3': '-800x600.jpg',
    'm4x3': '-640x480.jpg',
    'l4x3': '-400x300.jpg',
    'h16x7': '-800x350.jpg',
    'm16x7': '-640x280.jpg',
    'l16x7': '-400x175.jpg',
    'h2x1': '-800x400.jpg',
    'm2x1': '-640x320.jpg',
    'l2x1': '-400x200.jpg',
    'h16x9': '-800x450.jpg',
    'm16x9': '-640x360.jpg',
    'l16x9': '-400x225.jpg',
    'head': '-100x100',
    'default': '-noresize',
  };

  static Map<String, String> suffixMap({bool isIos = false}) =>
      isIos ? jpgSuffixMap : webpSuffixMap;

  /// Suffix for a size key such as `m3x4`; empty when the key is unknown.
  static String suffix(String size, {bool isIos = false}) =>
      suffixMap(isIos: isIos)[size] ?? '';

  static String defaultSuffix({bool isIos = false}) =>
      suffix('default', isIos: isIos);

  /// One page of a chapter.
  ///
  /// The backend ships a template with `$$` as the page placeholder, e.g.
  /// `.../comic/123/$$.jpg`, and the source iterated
  /// `for (var i = 1; i < startNum + endNum; i++)`.
  static String chapterPageUrl(ManhuataiChapter chapter, int pageNumber) {
    final template = chapter.chapterImage.middle.replaceAll(
      RegExp(r'\$\$'),
      '$pageNumber',
    );
    return '$mhHost$template';
  }

  /// Every page URL of a chapter, in reading order.
  static List<String> chapterPageUrls(ManhuataiChapter chapter) {
    final urls = <String>[];
    final limit = chapter.startNum + chapter.endNum;
    for (var i = 1; i < limit; i++) {
      urls.add(chapterPageUrl(chapter, i));
    }
    return urls;
  }

  /// Replica of `Utils.formatBookImgUrl`.
  ///
  /// Cover priority: explicit CMS path → forced default thumbnail → `2:1`
  /// special case → `m<width>x<height>` suffix by aspect ratio.
  static String cover({
    required int comicId,
    String imgUrl = '',
    String horizonratio = '3:4',
    bool useDefault = false,
    bool isIos = false,
  }) {
    final suffixes = suffixMap(isIos: isIos);
    if (imgUrl.isNotEmpty) {
      return '$cmsHost/$imgUrl${suffixes['default']}';
    }
    if (useDefault) {
      return '$imageHost/mh/$comicId.jpg${suffixes['default']}';
    }
    final ratioParts = horizonratio.split(':');
    final widthRatio = int.tryParse(ratioParts.first) ?? 3;
    final heightRatio =
        ratioParts.length > 1 ? int.tryParse(ratioParts[1]) ?? 4 : 4;
    if (heightRatio != 0 && widthRatio / heightRatio == 2.0) {
      return '$imageHost/mh/${comicId}_2_1.jpg${suffixes['m2x1']}';
    }
    // The source looked up `m<w>x<h>` and produced the literal "null" for an
    // unknown ratio; this port falls back to the default suffix instead.
    final key = 'm${widthRatio}x$heightRatio';
    return '$imageHost/mh/$comicId.jpg${suffixes[key] ?? suffixes['default']}';
  }

  /// Replica of `Utils.generateImgUrlFromId`.
  ///
  /// User heads are sharded into `000/123/456` segments from a 9-digit
  /// zero-padded id; comic images come from `/mh/`.
  static String fromId({
    required int id,
    String aspectRatio = '3:4',
    String type = '',
    bool isIos = false,
  }) {
    final suffixes = suffixMap(isIos: isIos);
    var host = imageHost;
    final ratioParts = aspectRatio.split(':');
    final widthRatio = int.tryParse(ratioParts.first) ?? 3;
    final heightRatio =
        ratioParts.length > 1 ? int.tryParse(ratioParts[1]) ?? 4 : 4;
    var size = 'm${widthRatio}x$heightRatio';
    var suffixValue = suffixes[size] ?? '';

    if (type == 'head') {
      host = '$headImgHost/kmh_user_head';
      size = 'head';
      suffixValue = suffixes[size] ?? '';
      const length = 9;
      final idStr = id.toString().padLeft(length, '0');
      final idFirst = idStr.substring(0, 3);
      final idSecond = idStr.substring(3, 6);
      final idThird = idStr.substring(6, 9);
      return '$host/$idFirst/$idSecond/$idThird.jpg$suffixValue';
    }

    if (size == 'm2x1') {
      return '$host/mh/${id}_2_1.jpg$suffixValue';
    }
    return '$host/mh/$id.jpg$suffixValue';
  }

  /// Replica of `Utils.formatNumber` (10000+ → 万, 100000000+ → 亿).
  static String formatNumber(String numberString) {
    final number = num.tryParse(numberString);
    if (number == null) {
      return numberString;
    }
    const wan = 10000;
    const tenWan = wan * 10;
    const yi = 100000000;
    if (number < tenWan) {
      return numberString;
    }
    if (number > tenWan && number < yi) {
      final ratioWan = number / wan;
      return ratioWan >= 100
          ? '${ratioWan.floor()}万'
          : '${ratioWan.toStringAsFixed(1)}万';
    }
    if (number > yi) {
      final ratioYi = number / yi;
      return ratioYi >= 100
          ? '${ratioYi.floor()}亿'
          : '${ratioYi.toStringAsFixed(1)}亿';
    }
    // Exactly 100000 / 100000000 reached no branch in the source (it returned
    // null); this port returns the original text.
    return numberString;
  }
}
