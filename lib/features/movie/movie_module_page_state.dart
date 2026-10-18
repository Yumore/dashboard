import 'package:dashboard/features/movie/movie_discover_tab.dart';
import 'package:dashboard/features/movie/movie_entry_tab.dart';
import 'package:dashboard/features/movie/movie_hub_controller.dart';
import 'package:dashboard/features/movie/movie_watchlist_tab.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:flutter/material.dart';

class MovieModulePageState extends State<MovieModulePage> {
  final _controller = MovieHubController();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final error = await _controller.load();
    if (!mounted || error == null) return;
    showContentError(context, error);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ModulePageScaffold(
        title: '影视',
        bottom: const TabBar(
          tabs: [
            Tab(text: '入口'),
            Tab(text: '发现'),
            Tab(text: '片单'),
          ],
        ),
        body: TabBarView(
          children: [
            const MovieEntryTab(),
            MovieDiscoverTab(controller: _controller),
            MovieWatchlistTab(controller: _controller),
          ],
        ),
      ),
    );
  }
}
