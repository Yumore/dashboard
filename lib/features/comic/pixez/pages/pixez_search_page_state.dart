import 'package:flutter/material.dart';

import '../controllers/pixez_search_controller.dart';
import '../models/pixez_search_options.dart';
import '../pixez_load_status.dart';
import '../widgets/pixez_error_view.dart';
import '../widgets/pixez_illust_grid.dart';
import '../widgets/pixez_login_required_view.dart';
import '../widgets/pixez_token_dialog.dart';
import '../widgets/pixez_user_preview_tile.dart';
import 'pixez_detail_page.dart';
import 'pixez_search_page.dart';
import 'pixez_user_page.dart';

class PixezSearchPageState extends State<PixezSearchPage> {
  late final PixezSearchController _controller;
  late final bool _ownsController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PixezSearchController();
    _searchController.text = _controller.word;
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _enterToken() async {
    final token = await showPixezTokenDialog(context);
    if (!mounted || token == null) return;
    await _controller.auth.saveAccessToken(token);
    await _submit();
  }

  Future<void> _submit() => _controller.search(_searchController.text);

  void _openDetail(int illustId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PixezDetailPage(illustId: illustId),
      ),
    );
  }

  void _openUser(int userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PixezUserPage(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pixiv 搜索')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        hintText: '搜索作品或作者',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _submit, child: const Text('搜索')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: false, label: Text('作品')),
                      ButtonSegment<bool>(value: true, label: Text('作者')),
                    ],
                    selected: <bool>{_controller.showUsers},
                    onSelectionChanged: (selection) {
                      _controller.setShowUsers(selection.first);
                      if (_controller.word.isNotEmpty) _submit();
                    },
                  ),
                  if (!_controller.showUsers)
                    DropdownButton<String>(
                      value: _controller.sort,
                      items: <DropdownMenuItem<String>>[
                        for (final sort in PixezSearchOptions.sorts)
                          DropdownMenuItem<String>(
                            value: sort,
                            child: Text(
                              PixezSearchOptions.sortLabels[sort] ?? sort,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        _controller.setSort(value);
                        if (_controller.word.isNotEmpty) _submit();
                      },
                    ),
                  if (!_controller.showUsers)
                    DropdownButton<String>(
                      value: _controller.searchTarget,
                      items: <DropdownMenuItem<String>>[
                        for (final target in PixezSearchOptions.targets)
                          DropdownMenuItem<String>(
                            value: target,
                            child: Text(
                              PixezSearchOptions.targetLabels[target] ??
                                  target,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        _controller.setSearchTarget(value);
                        if (_controller.word.isNotEmpty) _submit();
                      },
                    ),
                ],
              ),
            ),
            Expanded(child: _buildResults(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_controller.status == PixezLoadStatus.loginRequired) {
      return PixezLoginRequiredView(onEnterToken: _enterToken);
    }
    if (_controller.status == PixezLoadStatus.error) {
      return PixezErrorView(
        message: _controller.error ?? '搜索失败',
        onRetry: _submit,
      );
    }
    if (!_controller.hasSearched) {
      return const Center(child: Text('输入关键词开始搜索'));
    }
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.showUsers) {
      if (_controller.users.isEmpty) {
        return const Center(child: Text('没有找到作者'));
      }
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 320) {
            _controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _controller.users.length,
          itemBuilder: (context, index) {
            final preview = _controller.users[index];
            return PixezUserPreviewTile(
              preview: preview,
              onTap: () => _openUser(preview.user.id),
            );
          },
        ),
      );
    }
    if (_controller.illusts.isEmpty) {
      return const Center(child: Text('没有找到作品'));
    }
    return PixezIllustGrid(
      illusts: _controller.illusts,
      loading: _controller.loadingMore,
      onLoadMore: _controller.loadMore,
      onTap: (illust) => _openDetail(illust.id),
    );
  }
}
