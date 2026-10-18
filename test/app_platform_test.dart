import 'package:dashboard/app/platform/app_capability.dart';
import 'package:dashboard/app/platform/app_platform.dart';
import 'package:dashboard/app/platform/app_platform_kind.dart';
import 'package:dashboard/app/platform/app_platform_traits.dart';
import 'package:dashboard/features/anime/anime_entry_catalog.dart';
import 'package:dashboard/features/chat/chat_entry_catalog.dart';
import 'package:dashboard/features/comic/comic_entry_catalog.dart';
import 'package:dashboard/features/content_hub/content_module_catalog.dart';
import 'package:dashboard/features/live/live_entry_catalog.dart';
import 'package:dashboard/features/movie/movie_entry_catalog.dart';
import 'package:dashboard/features/novel/novel_entry_catalog.dart';
import 'package:dashboard/features/reading/reading_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _ioKinds = [
  AppPlatformKind.android,
  AppPlatformKind.ios,
  AppPlatformKind.macos,
  AppPlatformKind.windows,
  AppPlatformKind.linux,
  AppPlatformKind.ohos,
];

void main() {
  tearDown(AppPlatform.resetTraits);

  test('web disables io-only capabilities', () {
    const traits = AppPlatformTraits(AppPlatformKind.web);
    expect(traits.isWeb, isTrue);
    expect(traits.supportsFileSystem, isFalse);
    expect(traits.supportsSocket, isFalse);
    expect(traits.supportsVideoPlayback, isFalse);
    expect(traits.supportsSqlite, isTrue, reason: 'web 使用 wasm SQLite');
    expect(traits.supportsNativeToast, isTrue);
    expect(traits.supportsWebView, isFalse);
    expect(traits.supportsSelfUpdate, isFalse);
  });

  test('io platforms keep file system and socket support', () {
    for (final kind in _ioKinds) {
      final traits = AppPlatformTraits(kind);
      expect(traits.supportsFileSystem, isTrue, reason: '$kind');
      expect(traits.supportsSocket, isTrue, reason: '$kind');
      // media_kit 暂无 OHOS 原生库，鸿蒙按"不支持内嵌播放"处理。
      expect(
        traits.supportsVideoPlayback,
        kind != AppPlatformKind.ohos,
        reason: '$kind',
      );
    }
  });

  test('webview and self-update support is limited to plugin platforms', () {
    const supported = {
      AppPlatformKind.android,
      AppPlatformKind.ios,
      AppPlatformKind.macos,
    };
    const nativeToast = {
      AppPlatformKind.android,
      AppPlatformKind.ios,
      AppPlatformKind.web,
    };
    const brightness = {
      AppPlatformKind.android,
      AppPlatformKind.ios,
      AppPlatformKind.macos,
      AppPlatformKind.windows,
      AppPlatformKind.ohos,
    };
    for (final kind in AppPlatformKind.values) {
      final traits = AppPlatformTraits(kind);
      expect(traits.supportsWebView, supported.contains(kind), reason: '$kind');
      expect(
        traits.supportsNativeToast,
        nativeToast.contains(kind),
        reason: '$kind',
      );
      expect(
        traits.supportsScreenBrightness,
        brightness.contains(kind),
        reason: '$kind',
      );
      expect(
        traits.supportsSelfUpdate,
        kind == AppPlatformKind.android || kind == AppPlatformKind.ios,
        reason: '$kind',
      );
    }
  });

  test('channel and display name cover every platform', () {
    for (final kind in AppPlatformKind.values) {
      final traits = AppPlatformTraits(kind);
      expect(traits.channel, isNotEmpty, reason: '$kind');
      expect(traits.displayName, isNotEmpty, reason: '$kind');
    }
    expect(AppPlatformTraits(AppPlatformKind.ohos).channel, 'ohos');
    expect(AppPlatformTraits(AppPlatformKind.web).channel, 'web');
  });

  test('capability lookup follows the platform traits', () {
    AppPlatform.overrideTraits(const AppPlatformTraits(AppPlatformKind.web));
    expect(AppCapabilities.supports(AppCapability.fileSystem), isFalse);
    expect(AppCapabilities.supports(AppCapability.videoPlayback), isFalse);
    expect(AppCapabilities.supports(AppCapability.sqlite), isTrue);
    AppPlatform.overrideTraits(
      const AppPlatformTraits(AppPlatformKind.android),
    );
    expect(AppCapabilities.supports(AppCapability.fileSystem), isTrue);
    expect(AppCapabilities.supports(AppCapability.selfUpdate), isTrue);
  });

  test('catalog entries are unique across modules', () {
    final catalogs = [
      contentModuleCatalog,
      readingEntryCatalog,
      novelEntryCatalog,
      animeEntryCatalog,
      comicEntryCatalog,
      movieEntryCatalog,
      chatDemoCatalog,
      liveEntryCatalog,
    ];
    final ids = <String>[];
    for (final catalog in catalogs) {
      for (final section in catalog) {
        for (final entry in section.entries) {
          ids.add(entry.id);
        }
      }
    }
    expect(ids.toSet().length, ids.length, reason: 'entry id 必须全局唯一');
  });

  test('catalogs hide file-system entries on web', () {
    AppPlatform.overrideTraits(const AppPlatformTraits(AppPlatformKind.web));
    final movieIds = movieEntryCatalog
        .expand((section) => section.entries)
        .where((entry) => entry.isAvailable)
        .map((entry) => entry.id)
        .toSet();
    expect(movieIds, isNot(contains('bilibili-download')));
    expect(movieIds, isNot(contains('youtube-download')));
    expect(movieIds, isNot(contains('douyin')));
    expect(movieIds, isNot(contains('short-video-demo')));
    expect(movieIds, contains('inkino'));

    final readingIds = readingEntryCatalog
        .expand((section) => section.entries)
        .where((entry) => entry.isAvailable)
        .map((entry) => entry.id)
        .toSet();
    expect(readingIds, isNot(contains('feedbooks')));
    expect(readingIds, contains('alexandria'));

    final animeIds = animeEntryCatalog
        .expand((section) => section.entries)
        .where((entry) => entry.isAvailable)
        .map((entry) => entry.id)
        .toSet();
    expect(animeIds, isNot(contains('animetrace')));
    expect(animeIds, contains('takoplay'));
  });

  test('io platforms keep every catalog entry', () {
    AppPlatform.overrideTraits(
      const AppPlatformTraits(AppPlatformKind.android),
    );
    final all = [
      ...readingEntryCatalog,
      ...movieEntryCatalog,
      ...animeEntryCatalog,
    ].expand((section) => section.entries);
    for (final entry in all) {
      expect(entry.isAvailable, isTrue, reason: entry.id);
    }
  });

  testWidgets('section view hides entries that need missing capabilities', (
    tester,
  ) async {
    AppPlatform.overrideTraits(const AppPlatformTraits(AppPlatformKind.web));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContentEntrySectionView(section: movieEntryCatalog.first),
        ),
      ),
    );
    expect(find.text('B站视频下载'), findsNothing);
    expect(find.text('开眼 · Eyepetizer'), findsOneWidget);
  });
}
