import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';

/// Ports lib/network/eh_network/eh_models.dart.
class EhGalleryBrief extends BaseComic {
  const EhGalleryBrief(
    this.title,
    this.type,
    this.time,
    this.uploader,
    this.coverPath,
    this.stars,
    this.link,
    this.tags, {
    this.pages,
  });

  @override
  final String title;
  final String type;
  final String time;
  final String uploader;
  final double stars;
  final String coverPath;
  final String link;
  @override
  final List<String> tags;
  final int? pages;

  @override
  String get cover => coverPath;

  @override
  String get description => time;

  @override
  String get id => link;

  @override
  String get subTitle => uploader;

  @override
  bool get enableTagsTranslation => true;
}

/// Ports `Galleries`: a page of galleries plus the `#dnext` link.
class EhGalleries {
  EhGalleries([List<EhGalleryBrief>? galleries, this.next])
      : galleries = galleries ?? <EhGalleryBrief>[];

  List<EhGalleryBrief> galleries;
  String? next;

  int get length => galleries.length;

  EhGalleryBrief operator [](int index) => galleries[index];
}

/// Ports `Comment` from eh_models.dart.
class EhComment {
  const EhComment(
    this.id,
    this.name,
    this.content,
    this.time,
    this.score,
    this.voteUp,
  );

  final String id;
  final String name;
  final String content;
  final String time;
  final int score;

  /// true: up, false: down, null: not voted.
  final bool? voteUp;
}

/// Ports `Gallery` from eh_models.dart.
///
/// Deviation: the original stored `maxPage` as a `String` scraped from the
/// gallery page; this port keeps it an `int` because the core
/// `HistoryMixin.maxPage` is `int?`.
class EhGallery with HistoryMixin {
  EhGallery({
    required this.title,
    required this.type,
    required this.time,
    required this.uploader,
    required this.stars,
    required this.rating,
    required this.coverPath,
    required this.tags,
    required this.link,
    required this.maxPage,
    required this.favorite,
    this.subTitle,
    this.auth,
    List<EhComment>? comments,
    List<String>? thumbnails,
  })  : comments = comments ?? <EhComment>[],
        thumbnails = thumbnails ?? <String>[];

  @override
  final String title;
  @override
  final String? subTitle;
  final String type;
  final String time;
  final String uploader;
  final double stars;
  final String? rating;
  final String coverPath;
  final Map<String, List<String>> tags;
  final List<EhComment> comments;

  /// Auth variables scraped from the gallery page's inline JS
  /// (`getVariablesFromJsCode`), e.g. `gid`, `token`, `thumbnailKey`.
  final Map<String, String>? auth;
  final bool favorite;
  final String link;
  @override
  final int maxPage;
  final List<String> thumbnails;

  /// `namespace:name` for every tag, exactly like `_generateTags`.
  List<String> generateTags() {
    final result = <String>[];
    tags.forEach((key, value) {
      for (final element in value) {
        result.add('$key:$element');
      }
    });
    return result;
  }

  EhGalleryBrief toBrief() => EhGalleryBrief(
        title,
        type,
        time,
        uploader,
        coverPath,
        stars,
        link,
        generateTags(),
      );

  @override
  String get cover => coverPath;

  @override
  HistoryType get historyType => HistoryType.ehentai;

  @override
  String get target => link;
}

/// Ports `EhLeaderboardType`.
enum EhLeaderboardType {
  yesterday(15),
  month(13),
  year(12),
  all(11);

  const EhLeaderboardType(this.value);

  final int value;

  static EhLeaderboardType fromValue(int value) {
    for (final type in EhLeaderboardType.values) {
      if (type.value == value) return type;
    }
    throw ArgumentError.value(value, 'value', 'Invalid leaderboard type');
  }
}

/// Ports `EhLeaderboard`.
class EhLeaderboard {
  EhLeaderboard(this.type, this.galleries, this.loaded);

  final EhLeaderboardType type;
  final List<EhGalleryBrief> galleries;
  final int loaded;

  static const int max = 199;
}

/// Ports lib/network/eh_network/get_gallery_id.dart.
String getGalleryId(String url) {
  final start = url.indexOf('/g/') + 3;
  final buffer = StringBuffer();
  for (var i = start; i < url.length; i++) {
    if (url[i] == '/') break;
    buffer.write(url[i]);
  }
  return buffer.toString();
}

/// Ports `getStarsFromPosition`: maps the inline `background-position` style
/// of the rating widget onto a 0.5..5 star value.
double getStarsFromPosition(String position) {
  final end = position.indexOf(';');
  final value = end == -1 ? position : position.substring(0, end);
  switch (value) {
    case 'background-position:0px -1px':
      return 5;
    case 'background-position:0px -21px':
      return 4.5;
    case 'background-position:-16px -1px':
      return 4;
    case 'background-position:-16px -21px':
      return 3.5;
    case 'background-position:-32px -1px':
      return 3;
    case 'background-position:-32px -21px':
      return 2.5;
    case 'background-position:-48px -1px':
      return 2;
    case 'background-position:-48px -21px':
      return 1.5;
    case 'background-position:-64px -1px':
      return 1;
    case 'background-position:-64px -21px':
      return 0.5;
  }
  return 0.5;
}

/// Ports the `nums` string extension used all over the e-hentai parser.
String digitsOf(String text) {
  final matches = RegExp(r'\d+').allMatches(text);
  if (matches.isEmpty) return '';
  return matches.map((match) => match.group(0)).join();
}

/// Ports lib/tools/js.dart `getVariablesFromJsCode`.
Map<String, String> parseJsVariables(String html) {
  final variables = <String, String>{};
  final regex = RegExp(r'var\s+(\w+)\s*=\s*(.*?);');
  for (final match in regex.allMatches(html)) {
    final raw = match.group(2)!;
    if (raw.isEmpty) continue;
    if (raw[0] == '"' || raw[0] == "'") {
      variables[match.group(1)!] = raw.substring(1, raw.length - 1);
    } else {
      variables[match.group(1)!] = raw;
    }
  }
  return variables;
}

/// Builds a thumbnail URL from the scraped `thumbnailKey`.
///
/// Ports `EhNetwork.getThumbnailUrls`: `<key>/<gid>-<page>.jpg` with the key
/// zero padded to `/m/<n>/` for images above 20 per page.
String buildEhThumbnailUrl(String thumbnailKey, String galleryId, int page) =>
    '$thumbnailKey/$galleryId-$page.jpg';

/// Zero-pads the `/m/<n>/` segment of a scraped thumbnail key.
String buildEhThumbnailKey(String base, int page) {
  final folder = (page ~/ 20).toString().padLeft(2, '0');
  return '$base/m/$folder';
}
