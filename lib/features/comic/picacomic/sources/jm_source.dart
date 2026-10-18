import 'dart:collection';

import 'package:dashboard/features/comic/picacomic/core/account_config.dart';
import 'package:dashboard/features/comic/picacomic/core/account_info_item.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_data.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_options.dart';
import 'package:dashboard/features/comic/picacomic/core/category_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/comment.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_part.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:dashboard/features/comic/picacomic/core/favorite_data.dart';
import 'package:dashboard/features/comic/picacomic/core/fixed_category_part.dart';
import 'package:dashboard/features/comic/picacomic/core/ranking_data.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/core/search_options.dart';
import 'package:dashboard/features/comic/picacomic/core/search_page_data.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_comics_order.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_image_urls.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_network.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';

/// Ports the `jm` built-in source (PicaComic lib/comic_source/built_in/jm.dart).
///
/// Not ported: `comicPageBuilder` / `comicTileBuilderOverride` (the host renders
/// comics through its own pages) and the 每周推荐 button, which needs PicaComic's
/// `JmWeekRecommendationPage`; [JmNetwork.getWeekRecommendation] and
/// [JmNetwork.getWeekRecommendationComics] are nevertheless available.
final ComicSource jmSource = ComicSource(
  name: '禁漫天堂',
  key: 'jm',
  filePath: 'built-in',
  favoriteData: FavoriteData(
    key: 'jm',
    title: '禁漫天堂',
    multiFolder: true,
    loadComic: (i, [folder]) => _network().getFolderComicsPage(folder ?? '0', i),
    loadFolders: ([comicId]) => _network().getFolders(),
    deleteFolder: (id) => _network().deleteFolder(id),
    addFolder: (name) => _network().createFolder(name),
    allFavoritesId: '0',
    addOrDeleteFavorite: (id, folder, isAdding) async {
      if (isAdding) return Res.error('invalid');
      return _network().favorite(id, folder);
    },
  ),
  categoryData: CategoryData(
    title: '禁漫天堂',
    key: 'jm',
    enableRankingPage: true,
    categories: const [
      FixedCategoryPart(
        '成人A漫',
        [
          '最新A漫',
          '同人',
          '單本',
          '短篇',
          '其他類',
          '韓漫',
          '美漫',
          'Cosplay',
          '3D',
          '禁漫漢化組',
        ],
        'category',
        [
          '0',
          'doujin',
          'single',
          'short',
          'another',
          'hanman',
          'meiman',
          'another_cosplay',
          '3D',
          '禁漫漢化組',
        ],
      ),
      FixedCategoryPart(
        '主題A漫',
        [
          '無修正',
          '劇情向',
          '青年漫',
          '校服',
          '純愛',
          '人妻',
          '教師',
          '百合',
          'Yaoi',
          '性轉',
          'NTR',
          '女裝',
          '癡女',
          '全彩',
          '女性向',
          '完結',
          '純愛',
          '禁漫漢化組',
        ],
        'search',
      ),
      FixedCategoryPart(
        '角色扮演',
        [
          '御姐',
          '熟女',
          '巨乳',
          '貧乳',
          '女性支配',
          '教師',
          '女僕',
          '護士',
          '泳裝',
          '眼鏡',
          '連褲襪',
          '其他制服',
          '兔女郎',
        ],
        'search',
      ),
      FixedCategoryPart(
        '特殊PLAY',
        [
          '群交',
          '足交',
          '束縛',
          '肛交',
          '阿黑顏',
          '藥物',
          '扶他',
          '調教',
          '野外露出',
          '催眠',
          '自慰',
          '觸手',
          '獸交',
          '亞人',
          '怪物女孩',
          '皮物',
          'ryona',
          '騎大車',
        ],
        'search',
      ),
      FixedCategoryPart(
        '其它',
        ['CG', '重口', '獵奇', '非H', '血腥暴力', '站長推薦'],
        'search',
      ),
    ],
  ),
  categoryComicsData: CategoryComicsData(
    load: (category, param, options, page) => _network().getCategoryComics(
      param ?? category,
      JmComicsOrder.fromValue(options.isEmpty ? 'mr' : options.first),
      page,
    ),
    options: [
      CategoryComicsOptions(
        options: LinkedHashMap.of({
          'mr': '最新',
          'mv': '总排行',
          'mv_m': '月排行',
          'mv_w': '周排行',
          'mv_t': '日排行',
          'mp': '最多图片',
          'tf': '最多喜欢',
        }),
      ),
    ],
    rankingData: RankingData(
      options: const {
        'mv': '总排行',
        'mv_m': '月排行',
        'mv_w': '周排行',
        'mv_t': '日排行',
      },
      load: (option, page) => _network().getCategoryComics(
        '0',
        JmComicsOrder.fromValue(option),
        page,
      ),
    ),
  ),
  account: AccountConfig(
    registerWebsite: 'https://18comic.vip/signup',
    login: (account, pwd) async {
      final res = await _network().login(account, pwd);
      if (res.success) {
        await jmSource.saveAccount(account, pwd);
        jmSource.data['name'] = account;
        await jmSource.saveData();
      }
      return res;
    },
    logout: () {
      _network().logout();
      jmSource.data
        ..remove('name')
        ..remove('account');
      jmSource.saveData();
    },
    infoItems: [
      AccountInfoItem(
        title: '用户名',
        data: () => jmSource.data['name'] as String? ?? '',
      ),
    ],
  ),
  explorePages: [
    ExplorePageData(
      title: '禁漫主页',
      type: ExplorePageType.singlePageWithMultiPart,
      loadMultiPart: () async {
        final homePageData = await _network().getHomePage();
        if (homePageData.error) return Res.fromErrorRes(homePageData);
        return Res([
          for (final part in homePageData.data.items)
            ExplorePagePart(
              part.name,
              part.comics,
              'category:${part.name}@${part.id}',
            ),
        ]);
      },
    ),
    ExplorePageData(
      title: '禁漫最新',
      type: ExplorePageType.multiPageComicList,
      loadPage: (page) => _network().getLatest(page),
    ),
  ],
  matchBriefIdReg: r'^(\d+|jm\d+)$',
  searchPageData: SearchPageData(
    loadPage: (keyword, page, options) => _network().search(
      keyword,
      page,
      JmComicsOrder.fromValue(options.isEmpty ? 'mr' : options.first),
    ),
    searchOptions: [
      SearchOptions(
        LinkedHashMap.of({
          'mr': '最新',
          'mv': '总排行',
          'mv_m': '月排行',
          'mv_w': '周排行',
          'mv_t': '日排行',
          'mp': '最多图片',
          'tf': '最多喜欢',
        }),
        '排序',
      ),
    ],
  ),
  loadComicInfo: (id) async {
    final res = await _network().getComicInfo(id);
    if (res.error) return Res.fromErrorRes(res);
    final info = res.data;
    final sortedSeries = info.series.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final chapters = <String, String>{};
    for (var i = 0; i < sortedSeries.length; i++) {
      chapters[sortedSeries[i].value] = i < info.epNames.length
          ? info.epNames[i]
          : '第${sortedSeries[i].key}話';
    }
    return Res(
      ComicInfoData(
        info.name,
        info.firstAuthor,
        JmImageUrls.cover(info.id),
        info.description,
        {'标签': info.tags},
        chapters.isEmpty ? null : chapters,
        null,
        null,
        1,
        info.relatedComics,
        'jm',
        info.id,
        isFavorite: info.favorite,
      ),
    );
  },
  loadComicPages: (id, ep) => _network().getChapter(ep ?? id),
  getThumbnailLoadingConfig: (imageKey) => {
    'headers': {'User-Agent': webUserAgent},
  },
  commentsLoader: (id, subId, page, replyTo) async {
    final res = await _network().getComment(id, page, subId == null ? 'manhua' : 'all');
    if (res.error) return Res.fromErrorRes(res);
    return Res(
      [
        for (final c in res.data)
          Comment(c.name, c.avatar, c.content, c.time, c.reply.length, c.id),
      ],
      subData: res.subData,
    );
  },
  sendCommentFunc: (id, subId, content, replyTo) async {
    final res = await _network().comment(id, content);
    return res.error ? Res.fromErrorRes(res) : const Res(true);
  },
);

JmNetwork? _cachedJmNetwork;

/// Test seam: replaces the client used by every 禁漫天堂 request.
void setJmNetworkForTest(JmNetwork? network) {
  _cachedJmNetwork = network;
}

JmNetwork _network() => _cachedJmNetwork ??= JmNetwork(
  reLogin: () => jmSource.reLogin(),
);

/// The sort option values exposed by [jmSource]'s search page, in order.
List<String> get jmSearchOrderValues =>
    jmSource.searchPageData!.searchOptions!.first.options.keys.toList();

/// Convenience for screens: the first chapter id of a detail payload, or the
/// comic id itself when the comic is a one-shot.
String jmFirstChapterId(ComicInfoData info) {
  final chapters = info.chapters;
  if (chapters == null || chapters.isEmpty) return info.comicId;
  return chapters.keys.first;
}
