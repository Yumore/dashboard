import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_category.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_search_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_signing_notice.dart';
import 'package:flutter/material.dart';

/// 与源工程 `main.dart` 的 `DefaultTabController(length: 10)` 对齐。
class DyttPageState extends State<DyttPage> {
  late final bool _ownsApi;
  late final DyttApi _api;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DyttApi();
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => DyttSearchPage(api: _api)));
  }

  void _showSigningGap() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('签名不可用'),
        content: const SingleChildScrollView(child: DyttSigningNotice()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: DyttCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('电影天堂'),
          actions: [
            if (!_api.signingSupported)
              IconButton(
                tooltip: '签名不可用',
                icon: const Icon(Icons.lock_outline),
                onPressed: _showSigningGap,
              ),
            IconButton(
              tooltip: '搜索',
              icon: const Icon(Icons.search),
              onPressed: _openSearch,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final category in DyttCategory.values)
                Tab(text: category.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final category in DyttCategory.values)
              DyttListPage(category: category, api: _api),
          ],
        ),
      ),
    );
  }
}
