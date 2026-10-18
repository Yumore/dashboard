import 'package:flutter/material.dart';

import '../controllers/pixez_rank_controller.dart';
import '../pixez_load_status.dart';
import '../widgets/pixez_error_view.dart';
import '../widgets/pixez_illust_grid.dart';
import '../widgets/pixez_login_required_view.dart';
import '../widgets/pixez_token_dialog.dart';
import 'pixez_detail_page.dart';
import 'pixez_rank_page.dart';

class PixezRankPageState extends State<PixezRankPage> {
  late final PixezRankController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PixezRankController();
    if (_controller.status == PixezLoadStatus.idle) {
      _controller.load();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _enterToken() async {
    final token = await showPixezTokenDialog(context);
    if (!mounted || token == null) return;
    await _controller.auth.saveAccessToken(token);
    await _controller.load();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.date ?? now,
      firstDate: DateTime(2010),
      lastDate: now,
    );
    if (!mounted || picked == null) return;
    await _controller.selectDate(picked);
  }

  void _openDetail(int illustId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PixezDetailPage(illustId: illustId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixiv 排行榜'),
        actions: <Widget>[
          IconButton(
            tooltip: '选择日期',
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: _controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: <Widget>[
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _controller.modes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final mode = _controller.modes[index];
                  return ChoiceChip(
                    label: Text(mode.label),
                    selected: index == _controller.modeIndex,
                    onSelected: (_) => _controller.selectMode(index),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(_controller.requestDate ?? '默认日期'),
                    ),
                    if (_controller.date != null)
                      TextButton(
                        onPressed: () => _controller.selectDate(null),
                        child: const Text('清除'),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.status == PixezLoadStatus.loginRequired) {
      return PixezLoginRequiredView(onEnterToken: _enterToken);
    }
    if (_controller.status == PixezLoadStatus.error &&
        _controller.illusts.isEmpty) {
      return PixezErrorView(
        message: _controller.error ?? '排行榜加载失败',
        onRetry: _controller.load,
      );
    }
    if (_controller.illusts.isEmpty &&
        (_controller.status == PixezLoadStatus.loading ||
            _controller.status == PixezLoadStatus.idle)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.illusts.isEmpty) {
      return const Center(child: Text('没有排行榜作品'));
    }
    return PixezIllustGrid(
      illusts: _controller.illusts,
      loading: _controller.loadingMore,
      onLoadMore: _controller.loadMore,
      onTap: (illust) => _openDetail(illust.id),
    );
  }
}
