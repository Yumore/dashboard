import 'dart:async';

import 'package:dashboard/features/comic/picacomic/core/account_config.dart';
import 'package:dashboard/features/comic/picacomic/core/category_comics_data.dart';
import 'package:dashboard/features/comic/picacomic/core/category_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_data_store.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/favorite_data.dart';
import 'package:dashboard/features/comic/picacomic/core/search_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/setting_item.dart';
import 'package:dashboard/features/comic/picacomic/data/shared_preferences_comic_source_store.dart';

/// Ports PicaComic's `ComicSource` (`lib/comic_source/comic_source.dart`).
///
/// A source bundles the request/parse functions plus the declarative category,
/// search, explore and favorite descriptions used to build the UI.
class ComicSource {
  /// Display name.
  final String name;

  /// Stable identifier, also persisted inside history/favorite entries.
  final String key;

  final AccountConfig? account;

  /// Static category tags page description.
  final CategoryData? categoryData;

  /// Comics page for a clicked category tag.
  final CategoryComicsData? categoryComicsData;

  /// Favorite page description.
  final FavoriteData? favoriteData;

  final List<ExplorePageData> explorePages;

  final SearchPageData? searchPageData;

  final List<SettingItem> settings;

  final LoadComicFunc? loadComicInfo;

  final LoadComicPagesFunc? loadComicPages;

  final GetImageLoadingConfigFunc? getImageLoadingConfig;

  final GetThumbnailLoadingConfigFunc? getThumbnailLoadingConfig;

  /// Regex matched against a brief id to obtain the canonical comic id.
  final String? matchBriefIdReg;

  /// Custom comment support; `null` disables it.
  final CommentsLoader? commentsLoader;

  final SendCommentFunc? sendCommentFunc;

  /// `built-in` for the six shipped sources, a file path for user sources.
  final String filePath;

  final String url;

  final String version;

  /// Per-source account/settings bag, persisted through [store].
  final Map<String, dynamic> data;

  final ComicSourceDataStore store;

  /// Hook called once after [loadData] during registry init.
  final FutureOr<void> Function(ComicSource source)? initData;

  ComicSource({
    required this.name,
    required this.key,
    this.account,
    this.categoryData,
    this.categoryComicsData,
    this.favoriteData,
    this.explorePages = const [],
    this.searchPageData,
    this.settings = const [],
    this.loadComicInfo,
    this.loadComicPages,
    this.getImageLoadingConfig,
    this.getThumbnailLoadingConfig,
    this.matchBriefIdReg,
    this.commentsLoader,
    this.sendCommentFunc,
    this.filePath = 'built-in',
    this.url = '',
    this.version = '',
    this.initData,
    Map<String, dynamic>? data,
    ComicSourceDataStore? store,
  }) : data = data ?? <String, dynamic>{},
       store = store ?? const SharedPreferencesComicSourceStore();

  int get intKey => key.hashCode;

  bool get isBuiltIn => filePath == 'built-in';

  bool get isLogin => data['account'] != null;

  RegExp? get idMatcher =>
      matchBriefIdReg == null ? null : RegExp(matchBriefIdReg!);

  /// Loads persisted [data]. Called by the registry during init.
  Future<void> loadData() async {
    final loaded = await store.read(key);
    if (loaded != null) data.addAll(loaded);
  }

  bool _isSaving = false;

  /// Persists [data]. Concurrent calls are coalesced.
  Future<void> saveData() async {
    if (_isSaving) return;
    _isSaving = true;
    try {
      await store.write(key, data);
    } finally {
      _isSaving = false;
    }
  }

  /// Re-runs [AccountConfig.login] with the stored credentials.
  Future<bool> reLogin() async {
    final accountData = data['account'];
    final login = account?.login;
    if (accountData is! List || accountData.length < 2 || login == null) {
      return false;
    }
    final res = await login(
      accountData[0].toString(),
      accountData[1].toString(),
    );
    return !res.error;
  }

  /// Stores credentials so [reLogin] can restore the session.
  Future<void> saveAccount(String userName, String password) async {
    data['account'] = <String>[userName, password];
    await saveData();
  }

  /// Clears the session and persists the change.
  Future<void> logout() async {
    data.remove('account');
    data.remove('user');
    data.remove('token');
    await saveData();
  }

  @override
  String toString() => 'ComicSource($key)';
}
