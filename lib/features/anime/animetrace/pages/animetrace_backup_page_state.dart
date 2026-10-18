import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_backup.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_backup_page.dart';
import 'package:flutter/material.dart';

/// State of [AnimeTraceBackupPage].
class AnimeTraceBackupPageState extends State<AnimeTraceBackupPage> {
  late final AnimeTraceBackupService _service =
      widget.service ?? AnimeTraceBackupService(database: widget.database);

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<AnimeTraceBackupFile> _files = const <AnimeTraceBackupFile>[];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String _message = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final files = await _service.listDeviceBackups();
      if (!mounted) return;
      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _backupNow() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = '';
    });
    try {
      final file = await _service.backupToDevice();
      final files = await _service.listDeviceBackups();
      if (!mounted) return;
      setState(() {
        _files = files;
        _message = '已备份到 ${file.path}';
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _restore(AnimeTraceBackupFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('恢复备份'),
        content: Text('用「${file.fileName}」覆盖当前数据库？当前数据会被替换。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = '';
    });
    try {
      await _service.restoreFromDevice(file.path);
      if (!mounted) return;
      setState(() {
        _message = '已从 ${file.fileName} 恢复，请重新进入页面加载数据';
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _upload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = '请先填写 WebDAV 地址');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _message = '';
    });
    try {
      final remote = await _service.uploadToWebDav(
        baseUrl: url,
        user: _userController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _message = '已上传到 $remote';
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _download() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = '请先填写 WebDAV 地址');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _message = '';
    });
    try {
      await _service.downloadFromWebDav(
        baseUrl: url,
        user: _userController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _message = '已从 WebDAV 恢复，请重新进入页面加载数据';
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _busy = false;
      });
    }
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '出错了：$_error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_message),
                  ),
                Row(
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _busy ? null : () => unawaited(_backupNow()),
                      icon: const Icon(Icons.save_alt),
                      label: const Text('立即备份'),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _busy ? null : () => unawaited(_load()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('刷新列表'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_files.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('设备上还没有备份文件。'),
                  )
                else
                  for (final file in _files)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(file.fileName),
                      subtitle: Text(
                        '${_sizeLabel(file.sizeBytes)} · ${file.modified}',
                      ),
                      trailing: TextButton(
                        onPressed: _busy
                            ? null
                            : () => unawaited(_restore(file)),
                        child: const Text('恢复'),
                      ),
                    ),
                const Divider(height: 32),
                Text(
                  'WebDAV（可选）',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'WebDAV 地址',
                    hintText: 'https://example.com/dav',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: _busy ? null : () => unawaited(_upload()),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('上传备份'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: _busy ? null : () => unawaited(_download()),
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: const Text('下载并恢复'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('不会主动连接任何服务器；只有点击上传/下载并填写地址后才会访问。'),
              ],
            ),
    );
  }
}
