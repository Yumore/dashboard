import 'dart:collection';

import 'package:dashboard/features/reading/easymygo/component/home_component.dart';
import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
import 'package:dashboard/features/reading/easymygo/component/novel_component.dart';
import 'package:dashboard/features/reading/easymygo/component/search_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/registry/source_config_wrapper.dart';

/// The business-facing source registry.
///
/// Faithful port of `SourceBundle` (`lib/plugin/source/controller/
/// source_controller.dart`, EasyMyGo): sources are sorted by their config order,
/// disabled or failed sources are skipped, and each component is filed into the
/// interface map for its business (home / search / detailed / read) and media
/// type (manga / novel) — the original's eight `is` checks.
class SourceBundle {
  SourceBundle(List<SourceConfigWrapper> sourceList) {
    final sorted = List<SourceConfigWrapper>.of(sourceList)
      ..sort((a, b) => a.config.order.compareTo(b.config.order));
    for (final wrapper in sorted) {
      if (wrapper.source.isError) continue;
      if (!wrapper.config.enabled) continue;
      final identify = wrapper.identify;
      final isNovel = wrapper.info.type == SourceType.novel;
      _sourceMap[identify] = wrapper;
      for (final component in wrapper.source.components) {
        if (component is HomeComponent) {
          (isNovel ? novelHomeMap : mangaHomeMap)[identify] = component;
        }
        if (component is SearchComponent) {
          (isNovel ? novelSearchMap : mangaSearchMap)[identify] = component;
        }
        if (component is MangaComponent) {
          mangaDetailedMap[identify] = component;
        }
        if (component is NovelComponent) {
          novelDetailedMap[identify] = component;
        }
      }
    }
  }

  final LinkedHashMap<String, SourceConfigWrapper> _sourceMap =
      LinkedHashMap<String, SourceConfigWrapper>();

  final Map<String, HomeComponent> mangaHomeMap = <String, HomeComponent>{};
  final Map<String, SearchComponent> mangaSearchMap = <String, SearchComponent>{};
  final Map<String, MangaComponent> mangaDetailedMap = <String, MangaComponent>{};
  final Map<String, HomeComponent> novelHomeMap = <String, HomeComponent>{};
  final Map<String, SearchComponent> novelSearchMap = <String, SearchComponent>{};
  final Map<String, NovelComponent> novelDetailedMap = <String, NovelComponent>{};

  int get length => _sourceMap.length;

  bool get isEmpty => _sourceMap.isEmpty;

  SourceConfigWrapper? getSourceConfigWrapper(String identify) =>
      _sourceMap[identify];

  List<SourceConfigWrapper> getSourceConfigWrapperList() =>
      _sourceMap.values.toList();

  HomeComponent? getMangaHomeComponent(String identify) =>
      mangaHomeMap[identify];

  SearchComponent? getMangaSearchComponent(String identify) =>
      mangaSearchMap[identify];

  MangaComponent? getMangaDetailedComponent(String identify) =>
      mangaDetailedMap[identify];

  HomeComponent? getNovelHomeComponent(String identify) =>
      novelHomeMap[identify];

  SearchComponent? getNovelSearchComponent(String identify) =>
      novelSearchMap[identify];

  NovelComponent? getNovelDetailedComponent(String identify) =>
      novelDetailedMap[identify];

  HomeComponent? homeComponent(SourceType type, String identify) =>
      type == SourceType.novel
      ? novelHomeMap[identify]
      : mangaHomeMap[identify];

  SearchComponent? searchComponent(SourceType type, String identify) =>
      type == SourceType.novel
      ? novelSearchMap[identify]
      : mangaSearchMap[identify];

  MangaComponent? mangaComponent(String identify) => mangaDetailedMap[identify];

  NovelComponent? novelComponent(String identify) => novelDetailedMap[identify];

  List<String> getMangaHomeList() => mangaHomeMap.keys.toList();

  List<String> getMangaSearchList() => mangaSearchMap.keys.toList();

  List<String> getNovelHomeList() => novelHomeMap.keys.toList();

  List<String> getNovelSearchList() => novelSearchMap.keys.toList();

  List<SourceConfigWrapper> sourcesOf(SourceType type) =>
      _sourceMap.values.where((wrapper) => wrapper.info.type == type).toList();
}
