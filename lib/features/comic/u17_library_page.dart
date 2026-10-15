import 'package:dashboard/features/comic/u17_library_page_state.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:dashboard/features/comic/u17_source.dart';
import 'package:flutter/material.dart';

class U17LibraryPage extends StatefulWidget {
  const U17LibraryPage({this.source, this.store, super.key});

  final U17Source? source;
  final U17LibraryStore? store;

  @override
  State<U17LibraryPage> createState() => U17LibraryPageState();
}
