import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category_page_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';

/// One category's paged comic list
/// (`haka_comic/lib/views/categories/categories.dart`).
class HakaCategoryPage extends StatefulWidget {
  const HakaCategoryPage({
    super.key,
    required this.repository,
    required this.category,
    required this.favorites,
    required this.history,
    required this.records,
  });

  final HakaRepository repository;

  final HakaCategory category;

  final HakaFavoriteStore favorites;

  final HakaHistoryStore history;

  final HakaReadRecordStore records;

  @override
  State<HakaCategoryPage> createState() => HakaCategoryPageState();
}
