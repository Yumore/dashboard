import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_home_page_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';

/// Category grid of the home tab (`haka_comic/lib/views/home/home.dart`).
///
/// Body-only: the module page owns the scaffold and tab bar.
class HakaHomePage extends StatefulWidget {
  const HakaHomePage({
    super.key,
    required this.repository,
    required this.onOpenCategory,
  });

  final HakaRepository repository;

  final void Function(HakaCategory category) onOpenCategory;

  @override
  State<HakaHomePage> createState() => HakaHomePageState();
}
