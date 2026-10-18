import 'package:dashboard/features/shared/ui/content_entry_section.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_home_page.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_home_page.dart';
import 'package:dashboard/features/comic/pixez/pixez_entry.dart';
import 'package:dashboard/features/comic/u17_library_page.dart';
import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/views/comic/comic_home.dart';
import 'package:flutter/material.dart';

/// Comic business entries: the local library plus every online comic source.
///
/// Haka and Pixez keep their own entry classes because those classes also own
/// the page metadata used by their tests; the catalog only renders them.
final List<ContentEntrySection> comicEntryCatalog = [
  ContentEntrySection(
    title: '漫画库与漫画源',
    description: '本地书架优先，在线源按站点分组',
    entries: [
      ContentEntry(
        id: 'comic-home',
        title: '原有漫画库',
        subtitle: '本地书架、分类与阅读记录',
        icon: Icons.menu_book_outlined,
        accent: ContentAccents.comic,
        builder: (_) => const ComicHomePage(),
      ),
      ContentEntry(
        id: 'u17',
        title: '有妖气漫画源',
        subtitle: '列表、搜索、章节与图片阅读',
        icon: Icons.collections_bookmark_outlined,
        accent: ContentAccents.comic,
        builder: (_) => const U17LibraryPage(),
      ),
      ContentEntry(
        id: 'manhuatai',
        title: '漫画台 (321mh)',
        subtitle: '推荐、更新、排行、书架、搜索、分类、详情与图片阅读',
        icon: Icons.auto_stories_outlined,
        accent: ContentAccents.comic,
        builder: (_) => const ManhuataiHomePage(),
      ),
      ContentEntry(
        id: 'haka',
        title: HakaEntry.title,
        subtitle: HakaEntry.subtitle,
        icon: HakaEntry.icon,
        accent: ContentAccents.comic,
        builder: (_) => HakaEntry.page(),
      ),
      ContentEntry(
        id: 'picacomic',
        title: '哔咔漫画 PicaComic',
        subtitle: '多公开源漫画 · 首页 / 搜索 / 分类 / 详情 / 阅读器',
        icon: Icons.collections_bookmark_outlined,
        accent: ContentAccents.comic,
        builder: (_) => const PicacomicHomePage(),
      ),
      ContentEntry(
        id: 'pixez',
        title: PixezEntry.title,
        subtitle: PixezEntry.subtitle,
        icon: PixezEntry.icon,
        accent: ContentAccents.comic,
        builder: (_) => PixezEntry.page(),
      ),
    ],
  ),
];
