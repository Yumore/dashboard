import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:dashboard/features/reading/easymygo/shelf/shelf_page_state.dart';
import 'package:flutter/material.dart';

/// Local shelf + history screen (`watchStar()` / `watchHistory()` in EasyMyGo).
class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.service, this.libraryStore});

  final ReadingService service;
  final LibraryStore? libraryStore;

  @override
  State<ShelfPage> createState() => ShelfPageState();
}
