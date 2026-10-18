import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_edition.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_file_link.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 资源详情页状态（源工程 `ResInfoPage`）。
///
/// 数据来自 `Api.getResInfo(id:itemid:channel:season:episode:)`，响应里的
/// `item_list` 是各压片版本（`YyetsEdition`），每个版本下挂若干下载/播放链接
/// （`YyetsFileLink`）。源工程用 `ExpansionPanel` 默认展开第一个版本；链接点击
/// 走 `launchUri` 交给外部应用（磁力/ed2k 交给下载器）。
///
/// 移植说明：宿主没有源工程的 `item_app` 边下边播原生下载器，所以该能力只做
/// 信息展示，不伪造播放。
class YyetsResourcePageState extends State<YyetsResourcePage> {
  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  YyetsResourceDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ownedApi?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _api.getResourceDetail(
        id: widget.id,
        itemid: widget.itemid,
        channel: widget.channel,
        season: widget.season,
        episode: widget.episode,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } on YyetsException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _open(YyetsFileLink file) async {
    final ok = await widget.launcher.open(file.address, passwd: file.passwd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '已打开：${file.wayName.isEmpty ? '链接' : file.wayName}' : '打开失败',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '资源详情'),
        actions: <Widget>[
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: _body(detail),
    );
  }

  Widget _body(YyetsResourceDetail? detail) {
    if (detail == null || _loading || _error != null) {
      return YyetsStatusView(loading: _loading, error: _error, onRetry: _load);
    }
    if (detail.isEmpty) {
      return const YyetsStatusView(emptyText: '暂无可用资源');
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        if (detail.canDownloadAndPlay)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('边下边播'),
              subtitle: Text(detail.downloadAndPlayUri ?? ''),
              // 源工程这里调用原生下载器；宿主没有对应实现，只做说明。
              trailing: const Tooltip(
                message: '宿主未内置原生下载器，请使用下方下载链接',
                child: Icon(Icons.info_outline),
              ),
            ),
          ),
        for (var index = 0; index < detail.editions.length; index++)
          _editionTile(detail.editions[index], index),
      ],
    );
  }

  Widget _editionTile(YyetsEdition edition, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: edition.isDefaultExpanded(index),
        title: Text(edition.formatLabel.replaceAll('\t', ' ').trim()),
        subtitle: Text(edition.hasSize ? edition.size : '大小未知'),
        children: <Widget>[
          if (edition.files.isEmpty) const ListTile(title: Text('该版本暂无下载链接')),
          for (final file in edition.files) _fileTile(file),
        ],
      ),
    );
  }

  Widget _fileTile(YyetsFileLink file) {
    final enabled = file.hasAddress;
    return ListTile(
      dense: true,
      leading: Icon(_iconFor(file)),
      title: Text(file.displayText),
      subtitle: Text(
        <String>[
          if (file.wayName.trim().isNotEmpty) file.wayName,
          if (!file.isLaunchable && enabled) '需在外部下载器中打开',
        ].join(' · '),
      ),
      onTap: enabled ? () => _open(file) : null,
    );
  }

  IconData _iconFor(YyetsFileLink file) {
    if (file.isMagnet) return Icons.link;
    if (file.isEd2k) return Icons.swap_horiz;
    return Icons.download_outlined;
  }
}
