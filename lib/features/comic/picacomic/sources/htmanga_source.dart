import 'package:dashboard/features/comic/picacomic/core/account_config.dart';
import 'package:dashboard/features/comic/picacomic/core/account_info_item.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_data.dart';
import 'package:dashboard/features/comic/picacomic/core/category_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_part.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:dashboard/features/comic/picacomic/core/favorite_data.dart';
import 'package:dashboard/features/comic/picacomic/core/fixed_category_part.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/core/search_page_data.dart';
import 'package:dashboard/features/comic/picacomic/network/htmanga_network.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';

/// Ports the `htmanga` built-in source
/// (PicaComic lib/comic_source/built_in/ht_manga.dart).
///
/// Added on top of the original: `loadComicInfo` / `loadComicPages`, because
/// PicaComic's reader page fetched the gallery itself
/// (ht_manga.dart:196-205) while the host's reader contract asks the source for
/// them. Both delegate to the ported [HtmangaNetwork] methods unchanged.
///
/// Not ported: `comicTileBuilderOverride` / `comicPageBuilder` (host pages take
/// over) and `comicTileBuilderOverride`'s embedded-image headers, which live in
/// [getThumbnailLoadingConfig] / [getImageLoadingConfig] instead.
final ComicSource htMangaSource = ComicSource(
  name: '紳士漫畫',
  key: 'htmanga',
  filePath: 'built-in',
  favoriteData: FavoriteData(
    key: 'htmanga',
    title: '绅士漫画',
    multiFolder: true,
    loadComic: (i, [folder]) => _network().getFavoriteFolderComics(folder ?? '0', i),
    loadFolders: ([comicId]) => _network().getFolders(),
    allFavoritesId: '0',
    deleteFolder: (id) async {
      final res = await _network().deleteFolder(id);
      return res ? const Res(true) : Res.error('Network Error');
    },
    addFolder: (name) async {
      final res = await _network().createFolder(name);
      return res ? const Res(true) : Res.error('Network Error');
    },
    addOrDeleteFavorite: (id, folder, isAdding) async {
      if (isAdding) return Res.error('invalid');
      return _network().delFavorite(id);
    },
  ),
  categoryData: CategoryData(
    title: '绅士漫画',
    key: 'htmanga',
    enableRankingPage: false,
    categories: const [
      FixedCategoryPart('最新', ['最新漫画'], 'category', ['/albums.html']),
      FixedCategoryPart(
        '同人志',
        [
          '同人志',
          '同人志-汉化',
          '同人志-日语',
          '同人志-English',
          '同人志-CG画集',
          '同人志-3D漫画',
          '同人志-Cosplay',
        ],
        'category',
        [
          '/albums-index-cate-5.html',
          '/albums-index-cate-1.html',
          '/albums-index-cate-12.html',
          '/albums-index-cate-16.html',
          '/albums-index-cate-2.html',
          '/albums-index-cate-22.html',
          '/albums-index-cate-3.html',
        ],
      ),
      FixedCategoryPart(
        '单行本',
        ['单行本', '单行本-汉化', '单行本-日语', '单行本-English'],
        'category',
        [
          '/albums-index-cate-6.html',
          '/albums-index-cate-9.html',
          '/albums-index-cate-13.html',
          '/albums-index-cate-17.html',
        ],
      ),
      FixedCategoryPart(
        '杂志&短篇',
        ['杂志&短篇', '杂志&短篇-汉化', '杂志&短篇-日语', '杂志&短篇-English'],
        'category',
        [
          '/albums-index-cate-7.html',
          '/albums-index-cate-10.html',
          '/albums-index-cate-14.html',
          '/albums-index-cate-18.html',
        ],
      ),
      FixedCategoryPart(
        '韩漫',
        ['韩漫', '韩漫-汉化', '韩漫-其它'],
        'category',
        [
          '/albums-index-cate-19.html',
          '/albums-index-cate-20.html',
          '/albums-index-cate-21.html',
        ],
      ),
    ],
  ),
  categoryComicsData: CategoryComicsData(
    load: (category, param, options, page) {
      var target = param ?? category;
      if (!target.startsWith('http')) {
        target = HtmangaNetwork.defaultBaseUrl + target;
      }
      return _network().getComicList(target, page);
    },
  ),
  account: AccountConfig(
    registerWebsite: 'https://www.wnacg.com/albums.html',
    login: (account, pwd) async {
      final res = await _network().login(account, pwd);
      if (res.success) {
        htMangaSource.data['name'] = account;
        await htMangaSource.saveAccount(account, pwd);
        await htMangaSource.saveData();
      }
      return res;
    },
    logout: () {
      htMangaSource.data
        ..remove('name')
        ..remove('account');
      _network().logout();
      htMangaSource.saveData();
    },
    infoItems: [
      AccountInfoItem(
        title: '用户名',
        data: () => htMangaSource.data['name'] as String? ?? '',
      ),
    ],
  ),
  explorePages: [
    ExplorePageData(
      title: '绅士漫画',
      type: ExplorePageType.singlePageWithMultiPart,
      loadMultiPart: () async {
        final homepage = await _network().getHomePage();
        if (homepage.error) return Res.fromErrorRes(homepage);
        final links = homepage.data.links;
        final names = links.keys.toList();
        return Res([
          for (var i = 0; i < homepage.data.comics.length; i++)
            ExplorePagePart(
              names[i],
              homepage.data.comics[i],
              'category:${names[i]}@${links[names[i]]}',
            ),
        ]);
      },
    ),
  ],
  searchPageData: SearchPageData(
    loadPage: (keyword, page, options) => _network().search(keyword, page),
  ),
  loadComicInfo: (id) async {
    final res = await _network().getComicInfo(id);
    if (res.error) return Res.fromErrorRes(res);
    final info = res.data;
    final pageCount = info.pages <= 0 ? 1 : (info.pages / 20).ceil();
    return Res(
      ComicInfoData(
        info.name,
        info.uploader,
        info.coverPath,
        info.description,
        {'标签': info.tags.keys.toList()},
        {
          for (var i = 1; i <= pageCount; i++) '$i': '第 $i 页',
        },
        info.thumbnails.isEmpty ? null : info.thumbnails,
        (id, page) => _network().getThumbnails(id, page),
        pageCount,
        null,
        'htmanga',
        info.id,
      ),
    );
  },
  loadComicPages: (id, ep) => _network().getImages(id),
  getImageLoadingConfig: (imageKey, comicId, epId) => {
    'headers': {
      'User-Agent': webUserAgent,
      'Referer': HtmangaNetwork.defaultBaseUrl,
    },
  },
  getThumbnailLoadingConfig: (imageKey) => {
    'headers': {'User-Agent': webUserAgent},
  },
);

HtmangaNetwork? _cachedHtMangaNetwork;

/// Test seam: replaces the client used by every 紳士漫畫 request.
void setHtMangaNetworkForTest(HtmangaNetwork? network) {
  _cachedHtMangaNetwork = network;
}

HtmangaNetwork _network() => _cachedHtMangaNetwork ??= HtmangaNetwork(
  reLogin: () => htMangaSource.reLogin(),
);
