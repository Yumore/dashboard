import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_camera_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_comment_sheet.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_feed_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_header.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_search_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_tab_bar.dart';
import 'package:flutter/material.dart';

class FlutterTiktokDemoPageState extends State<FlutterTiktokDemoPage> {
  static const Key rootPageViewKey = Key('fluttertiktok_root_page_view');

  final PageController rootController = PageController(initialPage: 1);

  /// Mirrors the source `Map<int, bool> favoriteMap` keyed by feed index.
  final Map<int, bool> favorites = <int, bool>{};

  FlutterTiktokTab currentTab = FlutterTiktokTab.home;
  int headerTab = 0;

  @override
  void dispose() {
    rootController.dispose();
    super.dispose();
  }

  void openSearch() {
    rootController.animateToPage(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void openProfile() {
    rootController.animateToPage(
      2,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void closeOverlay() {
    rootController.animateToPage(
      1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FlutterTiktokCameraPage()),
    );
  }

  void toggleFavorite(int index) {
    setState(() => favorites[index] = !(favorites[index] ?? false));
  }

  void like(int index) {
    setState(() => favorites[index] = true);
  }

  void showComments(int index) {
    FlutterTiktokCommentSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterTiktokPalette.back1,
      body: PageView(
        key: rootPageViewKey,
        controller: rootController,
        children: <Widget>[
          FlutterTiktokSearchPage(onPop: closeOverlay),
          _middlePage(),
          FlutterTiktokProfilePage(canPop: true, onPop: closeOverlay),
        ],
      ),
    );
  }

  Widget _middlePage() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IndexedStack(
            key: const Key('fluttertiktok_tab_stack'),
            index: currentTab.index,
            children: <Widget>[
              FlutterTiktokFeedPage(
                favorites: favorites,
                onToggleFavorite: toggleFavorite,
                onLike: like,
                onComment: showComments,
                onAvatar: openProfile,
              ),
              const FlutterTiktokFollowPage(),
              const FlutterTiktokMessagePage(),
              const FlutterTiktokProfilePage(isSelfPage: true),
            ],
          ),
        ),
        if (currentTab == FlutterTiktokTab.home)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 44,
                  child: FlutterTiktokHeader(
                    selectedIndex: headerTab,
                    onSelected: (int index) =>
                        setState(() => headerTab = index),
                    onSearch: openSearch,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FlutterTiktokTabBar(
            current: currentTab,
            onSwitch: (FlutterTiktokTab tab) =>
                setState(() => currentTab = tab),
            onAdd: openCamera,
          ),
        ),
      ],
    );
  }
}
