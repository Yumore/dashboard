import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/core/search_page_data.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_models.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_network.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';

/// Ports the `hitomi` built-in source
/// (PicaComic lib/comic_source/built_in/hitomi.dart).
///
/// Deviations, all because the host drops the `comicPageBuilder` /
/// `comicTileBuilderOverride` / `overrideSearchResultBuilder` hooks:
/// * the original explore entry was `ExplorePageType.override` rendering
///   `HitomiHomePage`; this port exposes the same four home feeds plus the four
///   popular feeds as `multiPageComicList` pages driven by the identical
///   `.nozomi` urls (hitomi.dart:28-34 + hitomi_main_network.dart:184-204).
/// * `_HiComicTile._generateTags`' Chinese translation needs
///   `assets/tags.json` (translateTagsToCN), which the host cannot ship, so
///   tag names stay in their original language and `enableTagsTranslation`
///   is left true for the UI layer to handle.
/// * `searchPageData` was an override widget; here it is a real paged loader
///   over [HiNetwork.search], 100 ids per page (hitomi's search result page
///   paged the id list the same way).
final ComicSource hitomiSource = ComicSource(
  name: 'hitomi',
  key: 'hitomi',
  filePath: 'built-in',
  explorePages: [
    ExplorePageData(
      title: 'Hitomi 全部',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.homePageAll, page),
    ),
    ExplorePageData(
      title: 'Hitomi 中文',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.homePageCn, page),
    ),
    ExplorePageData(
      title: 'Hitomi 日文',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.homePageJp, page),
    ),
    ExplorePageData(
      title: 'Hitomi 英文',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.homePageEn, page),
    ),
    ExplorePageData(
      title: 'Hitomi 今日热门',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.todayPopular, page),
    ),
    ExplorePageData(
      title: 'Hitomi 本周热门',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.weekPopular, page),
    ),
    ExplorePageData(
      title: 'Hitomi 本月热门',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.monthPopular, page),
    ),
    ExplorePageData(
      title: 'Hitomi 年度热门',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _loadComicList(HitomiDataUrls.yearPopular, page),
    ),
  ],
  searchPageData: SearchPageData(
    enableLanguageFilter: true,
    loadPage: (keyword, page, options) => _search(keyword, page),
  ),
  loadComicInfo: (id) async {
    final res = await _network().getComicInfo(id);
    if (res.error) return Res.fromErrorRes(res);
    final comic = res.data;
    return Res(
      ComicInfoData(
        comic.title,
        comic.subTitle,
        comic.cover,
        comic.lang,
        {
          'Artists': comic.artists ?? ['N/A'],
          'Groups': comic.group,
          'Categories': [comic.type],
          'Time': [comic.time],
          'Languages': [comic.lang],
          'Tags': [for (final tag in comic.tags) tag.name],
        },
        {'1': '全部'},
        null,
        (id, page) => _network().getSmallThumbnails(comic),
        2,
        null,
        'hitomi',
        comic.id,
      ),
    );
  },
  loadComicPages: (id, ep) async {
    final info = await _network().getComicInfo(id);
    if (info.error) return Res.fromErrorRes(info);
    return _network().getImageUrls(info.data);
  },
  getImageLoadingConfig: (imageKey, comicId, epId) => {
    'headers': {
      'User-Agent': webUserAgent,
      'Referer': 'https://hitomi.la/reader/$epId.html',
    },
  },
  getThumbnailLoadingConfig: (imageKey) => {
    'headers': {'User-Agent': webUserAgent, 'Referer': 'https://hitomi.la/'},
  },
);

/// hitomi.dart:44-48 — thumbnail requests always carry the site referer.
Map<String, String> get hitomiThumbnailHeaders => {
  'User-Agent': webUserAgent,
  'Referer': 'https://hitomi.la/',
};

/// hitomi_home_page.dart:13-58: one 100-byte nozomi window, then briefs.
Future<Res<List<BaseComic>>> _loadComicList(String url, int page) async {
  final network = _network();
  final list = ComicList(url);
  for (var i = 1; i < page; i++) {
    final more = await network.loadNextPage(list);
    if (more.error) return Res.fromErrorRes(more);
    if (!more.data) break;
  }
  final loaded = await network.loadNextPage(list);
  if (loaded.error) return Res.fromErrorRes(loaded);
  if (!loaded.data && list.comicIds.isEmpty) return const Res([]);
  final briefs = await network.getComicBriefs(list.comicIds);
  if (briefs.error) return Res.fromErrorRes(briefs);
  return Res(briefs.data.cast<BaseComic>());
}

/// HitomiSearchPage paged the resolved id list 100 at a time.
const int hitomiSearchPageSize = 100;

Future<Res<List<BaseComic>>> _search(String keyword, int page) async {
  final network = _network();
  final res = await network.search(keyword);
  if (res.error) return Res.fromErrorRes(res);
  final ids = res.data;
  final start = (page - 1) * hitomiSearchPageSize;
  if (start >= ids.length) return const Res([]);
  final end = (start + hitomiSearchPageSize).clamp(0, ids.length);
  final briefs = await network.getComicBriefs(ids.sublist(start, end));
  if (briefs.error) return Res.fromErrorRes(briefs);
  return Res(briefs.data.cast<BaseComic>());
}

HiNetwork? _cachedHitomiNetwork;

/// Test seam: replaces the client used by every hitomi request.
void setHitomiNetworkForTest(HiNetwork? network) {
  _cachedHitomiNetwork = network;
  if (network != null) {
    HiNetwork.resetShared();
  }
}

HiNetwork _network() => _cachedHitomiNetwork ??= HiNetwork.shared();
