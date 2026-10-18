import 'package:dashboard/features/reading/easymygo/component/home_component.dart';
import 'package:dashboard/features/reading/easymygo/component/search_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_second_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_config_item.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/registry/source_bundle.dart';
import 'package:dashboard/features/reading/easymygo/registry/source_config_wrapper.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/service/book_detail_result.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_extension_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/inner_source_factory.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_extension_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_source_loader.dart';
import 'package:dashboard/features/reading/easymygo/store/source_config_store.dart';

/// Application service that wires the ported engine together.
///
/// This is the port's stand-in for EasyMyGo's controller layer
/// (`ExtensionController` → `SourceLoadController` → `SourceBundle` +
/// `SourceConfigController`), collapsed into one plain Dart object so the
/// screens stay thin and the whole pipeline is testable without a widget tree:
///
/// 1. the inner extension is always loaded first ([InnerSourceFactory]);
/// 2. imported rule packages from [SourceConfigStore.readPackages] are parsed by
///    [RuleExtensionLoader] (the port's replacement for `.mygopack` archives);
/// 3. every source is loaded through its [SourceLoader];
/// 4. the stored `enabled` / `order` settings are merged in and the
///    [SourceBundle] registry is built.
class ReadingService {
  ReadingService._({
    required this.configStore,
    required this.ruleSourceLoader,
    required List<ExtensionData> extensions,
    required List<SourceData> sources,
    required List<SourceConfigItem> configs,
    required SourceBundle bundle,
  }) : _extensions = extensions,
       _sources = sources,
       _configs = configs,
       _bundle = bundle;

  final SourceConfigStore configStore;
  final RuleSourceLoader ruleSourceLoader;

  List<ExtensionData> _extensions;
  List<SourceData> _sources;
  List<SourceConfigItem> _configs;
  SourceBundle _bundle;

  /// Registered sources after config filtering — the business registry.
  SourceBundle get bundle => _bundle;

  /// Every loaded source, including disabled and failed ones (settings page).
  List<SourceData> get allSources => List<SourceData>.unmodifiable(_sources);

  /// Every extension package, including failed imports.
  List<ExtensionData> get extensions => List<ExtensionData>.unmodifiable(_extensions);

  /// Current per-source settings, ordered.
  List<SourceConfigItem> get configs => List<SourceConfigItem>.unmodifiable(_configs);

  /// Loads the inner extension plus the stored rule packages.
  static Future<ReadingService> create({
    SourceConfigStore? configStore,
    RuleSourceLoader? ruleSourceLoader,
    bool persist = true,
  }) async {
    final store = configStore ?? SourceConfigStore();
    final loader = ruleSourceLoader ?? RuleSourceLoader.instance;
    final manifests = await store.readPackages();
    return _assemble(
      configStore: store,
      ruleSourceLoader: loader,
      manifests: manifests,
      persist: persist,
    );
  }

  /// Builds a service from explicit registers (the entry point tests use).
  static Future<ReadingService> fromRegisters({
    SourceConfigStore? configStore,
    RuleSourceLoader? ruleSourceLoader,
    List<String> manifests = const <String>[],
    List<ExtensionData> extraExtensions = const <ExtensionData>[],
    bool persist = true,
  }) => _assemble(
    configStore: configStore ?? SourceConfigStore(),
    ruleSourceLoader: ruleSourceLoader ?? RuleSourceLoader(),
    manifests: manifests,
    extraExtensions: extraExtensions,
    persist: persist,
  );

  static Future<ReadingService> _assemble({
    required SourceConfigStore configStore,
    required RuleSourceLoader ruleSourceLoader,
    List<String> manifests = const <String>[],
    List<ExtensionData> extraExtensions = const <ExtensionData>[],
    bool persist = true,
  }) async {
    final extensions = <ExtensionData>[];

    // The inner extension is always present and always first (EasyMyGo's
    // ExtensionController prepended it before scanning the extensions folder).
    const innerLoader = InnerExtensionLoader();
    extensions.add(innerLoader.load(InnerSourceFactory.innerExtensionInfo));

    final packageLoader = RuleExtensionLoader(sourceLoader: ruleSourceLoader);
    for (final manifest in manifests) {
      try {
        final info = packageLoader.parse(manifest);
        if (info == null) continue;
        extensions.add(packageLoader.load(info));
      } catch (error) {
        extensions.add(
          ExtensionData(
            info: const ExtensionInfo(
              fromPackage: '',
              label: '导入失败的扩展包',
              loadType: ExtensionLoaderType.js,
            ),
            state: ExtensionLoadState.error,
            errorMsg: '$error',
          ),
        );
      }
    }
    extensions.addAll(extraExtensions);

    final sources = <SourceData>[
      for (final extension in extensions) ...extension.sources,
    ];
    final configs = await configStore.syncConfigs(
      <SourceInfo>[for (final source in sources) source.source],
      persist: persist,
    );
    final configByIdentify = <String, SourceConfigItem>{
      for (final config in configs) config.identify: config,
    };
    final wrappers = <SourceConfigWrapper>[
      for (final source in sources)
        SourceConfigWrapper(
          config:
              configByIdentify[source.source.identify] ??
              SourceConfigItem(
                key: source.source.key,
                fromPackage: source.source.fromPackage,
              ),
          source: source,
        ),
    ];
    return ReadingService._(
      configStore: configStore,
      ruleSourceLoader: ruleSourceLoader,
      extensions: extensions,
      sources: sources,
      configs: configs,
      bundle: SourceBundle(wrappers),
    );
  }

  /// Re-reads config + packages and rebuilds the registry in place.
  Future<void> reload({bool persist = true}) async {
    final manifests = await configStore.readPackages();
    final next = await _assemble(
      configStore: configStore,
      ruleSourceLoader: ruleSourceLoader,
      manifests: manifests,
      persist: persist,
    );
    _extensions = next._extensions;
    _sources = next._sources;
    _configs = next._configs;
    _bundle = next._bundle;
  }

  SourceConfigWrapper? wrapperOf(String identify) =>
      _bundle.getSourceConfigWrapper(identify);

  SourceType? typeOf(String identify) => wrapperOf(identify)?.info.type;

  bool isEnabled(String identify) => _configOf(identify)?.enabled ?? true;

  int orderOf(String identify) => _configOf(identify)?.order ?? 999;

  SourceData? sourceDataOf(String identify) {
    for (final source in _sources) {
      if (source.source.identify == identify) return source;
    }
    return null;
  }

  Future<void> setEnabled(String identify, bool enabled) async {
    final config = _configOf(identify);
    if (config == null) return;
    await configStore.save(config.copyWith(enabled: enabled));
    await reload();
  }

  Future<void> setOrder(String identify, int order) async {
    final config = _configOf(identify);
    if (config == null) return;
    await configStore.save(config.copyWith(order: order));
    await reload();
  }

  Future<ExtensionInfo> importPackage(String manifest) async {
    final loader = RuleExtensionLoader(sourceLoader: ruleSourceLoader);
    final info = loader.parse(manifest);
    if (info == null) {
      throw const RuleException('扩展包没有声明 package');
    }
    loader.load(info);
    await configStore.addPackage(manifest);
    await reload();
    return info;
  }

  Future<void> removePackage(int index) async {
    await configStore.removePackageAt(index);
    await reload();
  }

  SourceConfigItem? _configOf(String identify) {
    for (final config in _configs) {
      if (config.identify == identify) return config;
    }
    return null;
  }

  // ---------------------------------------------------------------- businesses

  HomeComponent? _homeOf(String identify) {
    final type = typeOf(identify);
    if (type == null) return null;
    return _bundle.homeComponent(type, identify);
  }

  SearchComponent? _searchOf(String identify) {
    final type = typeOf(identify);
    if (type == null) return null;
    return _bundle.searchComponent(type, identify);
  }

  (ComponentPayload, T?) _unavailable<T>(String identify, String what) {
    return (_error(identify, what), null);
  }

  ComponentPayload _error(String identify, String what) {
    final wrapper = wrapperOf(identify);
    if (wrapper == null) {
      return ComponentPayload(
        code: ComponentPayload.codeBusinessError,
        msg: '书源未启用: $identify',
      );
    }
    return ComponentPayload(
      code: ComponentPayload.codeBusinessError,
      msg: '书源「${wrapper.info.label}」$what',
    );
  }

  Future<(ComponentPayload, List<BookHomeTab>?)> getHomeTab(String identify) {
    final component = _homeOf(identify);
    if (component == null) {
      return Future.value((_error(identify, '不支持首页'), null));
    }
    return component.getHomeTab();
  }

  Future<(ComponentPayload, List<BookSecondTab>?)> getSecondTab(
    String identify,
    BookHomeTab tab,
  ) {
    final component = _homeOf(identify);
    if (component == null) {
      return Future.value((_error(identify, '不支持二级页'), null));
    }
    return component.getSecondTab(tab);
  }

  Future<(ComponentPayload, BookHomePage?)> getPageWithHomeTab(
    String identify,
    BookHomeTab tab,
  ) {
    final component = _homeOf(identify);
    if (component == null) {
      return Future.value((_error(identify, '不支持首页'), null));
    }
    return component.getPageWithHomeTab(tab);
  }

  Future<(ComponentPayload, BookHomePage?)> getPageWithSecondTab(
    String identify,
    BookHomeTab tab,
    BookSecondTab secondTab,
  ) {
    final component = _homeOf(identify);
    if (component == null) {
      return Future.value((_error(identify, '不支持二级页'), null));
    }
    return component.getPageWithSecondTab(tab, secondTab);
  }

  Future<(ComponentPayload, List<BookCover>, String?)> loadHomeCovers(
    String identify,
    BookHomePage page,
    String key,
  ) {
    final component = _homeOf(identify);
    if (component == null) {
      return Future.value((
        _error(identify, '不支持首页'),
        const <BookCover>[],
        null,
      ));
    }
    return component.loadPageData(page, key);
  }

  /// Ported from `MangaBookSearchCoverPage`: `getInitKey` then `search`.
  Future<(ComponentPayload, List<BookCover>, String?)> search(
    String identify,
    String keyword,
  ) {
    final component = _searchOf(identify);
    if (component == null) {
      return Future.value((
        _error(identify, '不支持搜索'),
        const <BookCover>[],
        null,
      ));
    }
    return component.search(component.getInitKey(keyword), keyword);
  }

  /// Next search page using the key the previous response returned.
  Future<(ComponentPayload, List<BookCover>, String?)> searchMore(
    String identify,
    String key,
    String keyword,
  ) {
    final component = _searchOf(identify);
    if (component == null) {
      return Future.value((
        _error(identify, '不支持搜索'),
        const <BookCover>[],
        null,
      ));
    }
    return component.search(key, keyword);
  }

  Future<BookDetailResult> detail(String identify, BookSummary summary) async {
    final type = typeOf(identify);
    if (type == null) {
      return BookDetailResult(
        payload: ComponentPayload(
          code: ComponentPayload.codeBusinessError,
          msg: '书源未启用: $identify',
        ),
      );
    }
    if (type == SourceType.manga) {
      final component = _bundle.mangaComponent(identify);
      if (component == null) {
        return BookDetailResult(
          payload: ComponentPayload(
            code: ComponentPayload.codeBusinessError,
            msg: '书源「${wrapperOf(identify)?.info.label}」不支持详情',
          ),
        );
      }
      final (payload, detailed, chapters) = await component.getMangaDetailed(
        summary,
      );
      return BookDetailResult(
        payload: payload,
        detailed: detailed,
        chapters: chapters ?? const <MangaChapter>[],
      );
    }
    final component = _bundle.novelComponent(identify);
    if (component == null) {
      return BookDetailResult(
        payload: ComponentPayload(
          code: ComponentPayload.codeBusinessError,
          msg: '书源「${wrapperOf(identify)?.info.label}」不支持详情',
        ),
      );
    }
    final (payload, detailed, volumes) = await component.getNovelDetailed(
      summary,
    );
    return BookDetailResult(
      payload: payload,
      detailed: detailed,
      volumes: volumes ?? const <NovelVolume>[],
    );
  }

  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    String identify,
    BookSummary summary,
    MangaChapter chapter,
  ) {
    final component = _bundle.mangaComponent(identify);
    if (component == null) {
      return Future.value(
        _unavailable<List<MangaPicture>>(identify, '不支持漫画阅读'),
      );
    }
    return component.getMangaPictures(chapter, summary);
  }

  Future<(ComponentPayload, List<NovelChapter>?)> getNovelChapters(
    String identify,
    BookSummary summary,
    NovelVolume volume,
  ) {
    final component = _bundle.novelComponent(identify);
    if (component == null) {
      return Future.value(
        _unavailable<List<NovelChapter>>(identify, '不支持小说阅读'),
      );
    }
    return component.getNovelChapters(volume, summary);
  }

  Future<(ComponentPayload, String)> loadNovelChapter(
    String identify,
    BookSummary summary,
    NovelChapter chapter,
  ) {
    final component = _bundle.novelComponent(identify);
    if (component == null) {
      return Future.value((_error(identify, '不支持小说阅读'), ''));
    }
    return component.loadNovelChapter(chapter, summary);
  }
}
