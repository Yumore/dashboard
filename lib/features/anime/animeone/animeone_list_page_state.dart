import 'package:dashboard/features/anime/animeone/animeone_error_button.dart';
import 'package:dashboard/features/anime/animeone/animeone_info.dart';
import 'package:dashboard/features/anime/animeone/animeone_info_card.dart';
import 'package:dashboard/features/anime/animeone/animeone_list_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_season.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeOneListPageState extends State<AnimeOneListPage> {
  late final AnimeOneSiteClient _client;
  AnimeOneSiteClient? _ownedClient;
  late final AnimeOneWatchStore _store;

  final TextEditingController searchController = TextEditingController();
  final List<AnimeOneInfo> all = [];
  List<AnimeOneInfo> list = [];
  List<({String label, String value})> quickFilters = const [];
  String? selectedFilter;
  String searchText = '';
  String error = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? (_ownedClient = AnimeOneSiteClient());
    _store = widget.watchStore ?? AnimeOneWatchStore();
    quickFilters = AnimeOneSeason(DateTime.now()).quickFilters();
    _load();
  }

  @override
  void dispose() {
    searchController.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = '';
    });
    final result = await _client.getAnimeList();
    if (!mounted) return;
    setState(() {
      all
        ..clear()
        ..addAll(result);
      loading = false;
      if (result.isEmpty) {
        error = _client.blocked ? '访问被站点拒绝，请稍后再试' : '';
      }
      _applyFilters();
    });
  }

  /// 关键字 + 快速筛选（两者是“与”关系）。
  void _applyFilters() {
    setState(() {
      list = all.where((info) {
        final filter = selectedFilter;
        if (filter != null && !info.contains(filter)) return false;
        if (searchText.isNotEmpty && !info.contains(searchText)) return false;
        return true;
      }).toList();
    });
  }

  void onSearchChanged(String text) {
    searchText = text;
    _applyFilters();
  }

  void toggleFilter(String value) {
    selectedFilter = selectedFilter == value ? null : value;
    _applyFilters();
  }

  void resetList() {
    selectedFilter = null;
    searchText = '';
    searchController.clear();
    setState(() => list = List.of(all));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.search, size: 28),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                autocorrect: false,
                decoration: const InputDecoration.collapsed(hintText: '快速搜索'),
                onChanged: onSearchChanged,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty && all.isEmpty
          ? AnimeOneErrorButton(message: error, onRetry: _load)
          : Column(
              children: [
                _renderQuickFilter(),
                Expanded(child: _renderBody()),
              ],
            ),
    );
  }

  Widget _renderQuickFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in quickFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: FilterChip(
                label: Text(filter.label),
                selected: selectedFilter == filter.value,
                onSelected: (_) => toggleFilter(filter.value),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: '重置列表',
            onPressed: resetList,
          ),
        ],
      ),
    );
  }

  Widget _renderBody() {
    if (list.isEmpty) {
      return const Center(child: Text('没有找到相关动画'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => AnimeOneInfoCard(
        info: list[index],
        index: index,
        client: widget.client,
        watchStore: _store,
      ),
    );
  }
}
