import 'package:dashboard/features/anime/animeone/animeone_error_button.dart';
import 'package:dashboard/features/anime/animeone/animeone_latest_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_recent.dart';
import 'package:dashboard/features/anime/animeone/animeone_recent_tile.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeOneLatestPageState extends State<AnimeOneLatestPage> {
  late final AnimeOneSiteClient _client;
  AnimeOneSiteClient? _ownedClient;
  late final AnimeOneWatchStore _store;

  List<AnimeOneRecent> list = [];
  String error = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? (_ownedClient = AnimeOneSiteClient());
    _store = widget.watchStore ?? AnimeOneWatchStore();
    _load();
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = '';
    });
    final result = await _client.getRecent();
    if (!mounted) return;
    setState(() {
      list = result;
      loading = false;
      if (result.isEmpty) {
        error = _client.blocked ? '访问被站点拒绝，请稍后再试' : '暂时没有更新';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近更新'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? AnimeOneErrorButton(message: error, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => AnimeOneRecentTile(
                  recent: list[index],
                  client: widget.client,
                  watchStore: _store,
                ),
              ),
            ),
    );
  }
}
