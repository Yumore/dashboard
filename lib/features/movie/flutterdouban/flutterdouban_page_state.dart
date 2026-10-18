import 'package:dashboard/features/movie/flutterdouban/flutterdouban_category.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_load_state.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_provenance_banner.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_settings_store.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_factory.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_status_view.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_tile.dart';
import 'package:flutter/material.dart';

/// State for [FlutterDouBanPage].
///
/// Every request is started from `initState`, a tab listener or a user
/// callback — never from `build`.
class FlutterDouBanPageState extends State<FlutterDouBanPage>
    with SingleTickerProviderStateMixin {
  final FlutterDouBanSettingsStore _settings =
      const FlutterDouBanSettingsStore();

  final Map<
    FlutterDouBanCategory,
    FlutterDouBanLoadState<List<FlutterDouBanSubjectRow>>
  >
  _categories =
      <
        FlutterDouBanCategory,
        FlutterDouBanLoadState<List<FlutterDouBanSubjectRow>>
      >{
        for (final category in FlutterDouBanCategory.values)
          category: FlutterDouBanLoadState<List<FlutterDouBanSubjectRow>>(),
      };

  late final TabController _tabs;
  FlutterDouBanDataSource? _source;
  bool _useNetData = FlutterDouBanSettingsStore.defaultUseNetData;
  bool _switching = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: FlutterDouBanCategory.values.length,
      vsync: this,
    )..addListener(_handleTabChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_handleTabChanged)
      ..dispose();
    _source?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final stored = widget.initialUseNetData ?? await _settings.loadUseNetData();
    if (!mounted) return;
    setState(() {
      _useNetData = stored;
      _source = _createSource(stored);
    });
    await _load(FlutterDouBanCategory.values[_tabs.index]);
  }

  FlutterDouBanDataSource _createSource(bool useNetData) =>
      createFlutterDouBanSource(
        useNetData: useNetData,
        dio: widget.dio,
        assetLoader: widget.assetLoader,
      );

  void _handleTabChanged() {
    if (_tabs.indexIsChanging) return;
    _load(FlutterDouBanCategory.values[_tabs.index]);
  }

  Future<void> _load(
    FlutterDouBanCategory category, {
    bool force = false,
  }) async {
    final state = _categories[category]!;
    final source = _source;
    if (source == null || state.loading) return;
    if (state.hasData && !force) return;
    setState(() {
      state.loading = true;
      state.error = null;
      if (force) state.data = null;
    });
    try {
      final data = await source.category(category);
      if (!mounted) return;
      setState(() {
        state.data = data;
        state.error = null;
        state.loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        state.error = error;
        state.loading = false;
      });
    }
  }

  /// Flips the ported `useNetData` flag, persists it under the source's own
  /// preference key and reloads the visible tab from the other backend.
  Future<void> _toggleSource() async {
    if (_switching) return;
    final value = !_useNetData;
    setState(() => _switching = true);
    await _settings.saveUseNetData(value);
    if (!mounted) return;
    _source?.dispose();
    for (final state in _categories.values) {
      state.reset();
    }
    setState(() {
      _useNetData = value;
      _source = _createSource(value);
      _switching = false;
    });
    final label = value ? '网络' : 'Mock';
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('数据来源已切换为$label')));
    await _load(FlutterDouBanCategory.values[_tabs.index], force: true);
  }

  void _openSubject(FlutterDouBanSubjectRow row) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterDouBanSubjectPage(
          subjectId: row.id,
          title: row.subject.displayTitle,
          useNetData: _useNetData,
          dio: widget.dio,
          assetLoader: widget.assetLoader,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterDouBanSearchPage(
          useNetData: _useNetData,
          dio: widget.dio,
          assetLoader: widget.assetLoader,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('豆瓣电影'),
        actions: [
          IconButton(
            tooltip: _useNetData
                ? '数据来源：网络 api.douban.com（点击切换 Mock）'
                : '数据来源：本地 Mock（点击切换网络）',
            onPressed: _switching ? null : _toggleSource,
            icon: Icon(
              _useNetData
                  ? Icons.cloud_done_outlined
                  : Icons.sd_storage_outlined,
            ),
          ),
          IconButton(
            tooltip: '搜索豆瓣电影',
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            for (final category in FlutterDouBanCategory.values)
              Tab(text: category.label),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          for (final category in FlutterDouBanCategory.values)
            _categoryBody(category),
        ],
      ),
    );
  }

  Widget _categoryBody(FlutterDouBanCategory category) {
    final state = _categories[category]!;
    if (state.loading && !state.hasData) {
      return const FlutterDouBanStatusView.loading();
    }
    if (state.hasError && !state.hasData) {
      return FlutterDouBanStatusView.error(
        '加载失败：${state.error}',
        onRetry: () => _load(category, force: true),
      );
    }
    final FlutterDouBanData<List<FlutterDouBanSubjectRow>>? data = state.data;
    if (data == null) return const FlutterDouBanStatusView.loading();
    final rows = data.value;
    return Column(
      children: [
        FlutterDouBanProvenanceBanner(
          data: data,
          trailing: '共 ${rows.length} 条',
        ),
        Expanded(
          child: rows.isEmpty
              ? const FlutterDouBanStatusView.empty('暂无数据')
              : RefreshIndicator(
                  onRefresh: () => _load(category, force: true),
                  child: ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return FlutterDouBanSubjectTile(
                        row: row,
                        onTap: () => _openSubject(row),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
