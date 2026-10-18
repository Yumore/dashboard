import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_page_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';

/// Comic detail with chapter list and resume support
/// (`haka_comic/lib/views/comic_details/comic_details.dart`).
class HakaComicDetailPage extends StatefulWidget {
  const HakaComicDetailPage({
    super.key,
    required this.repository,
    required this.comicId,
    required this.history,
    required this.favorites,
    required this.records,
  });

  final HakaRepository repository;

  final String comicId;

  final HakaHistoryStore history;

  final HakaFavoriteStore favorites;

  final HakaReadRecordStore records;

  @override
  State<HakaComicDetailPage> createState() => HakaComicDetailPageState();
}
