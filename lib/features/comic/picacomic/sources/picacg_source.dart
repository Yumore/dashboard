import 'dart:collection';

import 'package:dashboard/features/comic/picacomic/core/account_config.dart';
import 'package:dashboard/features/comic/picacomic/core/account_info_item.dart';
import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_data.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_options.dart';
import 'package:dashboard/features/comic/picacomic/core/category_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_part.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:dashboard/features/comic/picacomic/core/favorite_data.dart';
import 'package:dashboard/features/comic/picacomic/core/fixed_category_part.dart';
import 'package:dashboard/features/comic/picacomic/core/ranking_data.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/core/search_options.dart';
import 'package:dashboard/features/comic/picacomic/core/search_page_data.dart';
import 'package:dashboard/features/comic/picacomic/network/picacg_network.dart';

/// Ports lib/comic_source/built_in/picacg.dart.
final ComicSource picacgSource = ComicSource(
  name: 'picacg',
  key: 'picacg',
  filePath: 'built-in',
  initData: (source) {
    source.data['appChannel'] ??= '3';
    source.data['imageQuality'] ??= 'original';
  },
  account: AccountConfig(
    login: (account, password) async {
      final login = await _network.login(account, password);
      if (login.error) return Res.error(login.errorMessageWithoutNull);
      picacgSource.data['token'] = login.data;
      final profile = await _network.getProfile();
      if (profile.success) {
        picacgSource.data['user'] = profile.data.toJson();
      }
      await picacgSource.saveAccount(account, password);
      await picacgSource.saveData();
      return const Res(true);
    },
    logout: () {
      picacgSource.data.remove('token');
      picacgSource.data.remove('user');
    },
    infoItems: <AccountInfoItem>[
      AccountInfoItem(
        title: '账号',
        data: () => picacgSource.data['token']?.toString() ?? '',
      ),
      AccountInfoItem(
        title: '用户名',
        data: () => _userField('name'),
      ),
      AccountInfoItem(
        title: '等级',
        data: () => 'Lv${_userField('level')} ${_userField('exp')} Exp',
      ),
      AccountInfoItem(title: '简介', data: () => _userField('slogan')),
    ],
  ),
  categoryData: CategoryData(
    title: 'Picacg',
    key: 'picacg',
    enableRankingPage: true,
    categories: const <FixedCategoryPart>[
      FixedCategoryPart('分类', _categories, 'category'),
    ],
  ),
  categoryComicsData: CategoryComicsData(
    options: <CategoryComicsOptions>[
      CategoryComicsOptions(
        options: LinkedHashMap<String, String>.from(<String, String>{
          'dd': '新到旧',
          'da': '旧到新',
          'ld': '最多喜欢',
          'vd': '最多指名',
        }),
        notShowWhen: const <String>['random', 'latest'],
      ),
    ],
    rankingData: RankingData(
      options: const <String, String>{'H24': '24小时', 'D7': '7天', 'D30': '30天'},
      load: (option, page) => _network.getLeaderboard(option),
    ),
    load: (category, param, options, page) {
      if (category == 'random') return _network.getRandomComics();
      if (category == 'latest') return _network.getLatest(page);
      return _network.getCategoryComics(
        category: category,
        page: page,
        type: param ?? 'c',
        sort: options.isEmpty ? 'dd' : options[0],
      );
    },
  ),
  explorePages: <ExplorePageData>[
    ExplorePageData(
      title: 'picacg',
      type: ExplorePageType.singlePageWithMultiPart,
      loadMultiPart: () async {
        final results = await Future.wait(<Future<Res<List<BaseComic>>>>[
          _network.getRandomComics(),
          _network.getLatest(1),
        ]);
        for (final result in results) {
          if (result.error) return Res.error(result.errorMessageWithoutNull);
        }
        return Res(<ExplorePagePart>[
          ExplorePagePart('随机', results[0].data, 'category:random'),
          ExplorePagePart('最新', results[1].data, 'category:latest'),
        ]);
      },
    ),
  ],
  searchPageData: SearchPageData(
    searchOptions: <SearchOptions>[
      SearchOptions(
        LinkedHashMap<String, String>.from(<String, String>{
          'dd': '新到旧',
          'da': '旧到新',
          'ld': '最多喜欢',
          'vd': '最多指名',
        }),
        '排序',
      ),
    ],
    loadPage: (keyword, page, searchOption) => _network.search(
      keyword,
      searchOption.isEmpty ? 'dd' : searchOption[0],
      page,
    ),
  ),
  favoriteData: FavoriteData(
    key: 'picacg',
    title: 'picacg',
    multiFolder: false,
    loadComic: (page, [folder]) => _network.getFavorites(page),
    addOrDeleteFavorite: (comicId, folderId, isAdding) =>
        _network.favouriteOrUnfavouriteComic(comicId),
  ),
  loadComicInfo: (id) async {
    final res = await _network.getComicInfo(id);
    if (res.error) return Res.error(res.errorMessageWithoutNull);
    final comic = res.data;
    return Res(
      ComicInfoData(
        comic.title,
        comic.subTitle,
        comic.cover,
        comic.description,
        <String, List<String>>{
          '标签': comic.tags,
          '分类': comic.categories,
        },
        <String, String>{
          for (var index = 0; index < comic.eps.length; index++)
            '${index + 1}': comic.eps[index],
        },
        <String>[comic.cover],
        null,
        1,
        comic.recommendation,
        'picacg',
        comic.id,
        isFavorite: comic.isFavourite,
        subId: null,
      ),
    );
  },
  loadComicPages: (id, ep) => _network.getComicContent(
    id,
    int.tryParse(ep ?? '1') ?? 1,
  ),
  commentsLoader: (id, subId, page, replyTo) => _network.loadComments(
    id,
    page: page,
  ),
  sendCommentFunc: (id, subId, content, replyTo) =>
      _network.sendComment(id, content, replyTo: replyTo),
);

PicacgNetwork? _picacgNetwork;

PicacgNetwork get _network => _picacgNetwork ??= PicacgNetwork(
  tokenProvider: () => picacgSource.data['token']?.toString() ?? '',
  appChannelProvider: () =>
      picacgSource.data['appChannel']?.toString() ?? '3',
  imageQualityProvider: () =>
      picacgSource.data['imageQuality']?.toString() ?? 'original',
  reLogin: picacgSource.reLogin,
);

String _userField(String field) {
  final user = picacgSource.data['user'];
  if (user is Map) return user[field]?.toString() ?? '';
  return '';
}

/// The 40 Picacg categories, verbatim from the original `_categories` list.
const List<String> _categories = <String>[
  '大家都在看',
  '大濕推薦',
  '那年今天',
  '官方都在看',
  '嗶咔漢化',
  '全彩',
  '長篇',
  '同人',
  '短篇',
  '圓神領域',
  '碧藍幻想',
  'CG雜圖',
  '英語 ENG',
  '生肉',
  '純愛',
  '百合花園',
  '耽美花園',
  '偽娘哲學',
  '後宮閃光',
  '扶他樂園',
  '單行本',
  '姐姐系',
  '妹妹系',
  'SM',
  '性轉換',
  '足の恋',
  '人妻',
  'NTR',
  '強暴',
  '非人類',
  '艦隊收藏',
  'Love Live',
  'SAO 刀劍神域',
  'Fate',
  '東方',
  'WEBTOON',
  '禁書目錄',
  '歐美',
  'Cosplay',
  '重口地帶',
];

/// Exposed for tests: the category list is part of the protocol surface.
List<String> get picacgCategories => _categories;
