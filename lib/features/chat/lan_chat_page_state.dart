import 'package:dashboard/features/chat/lan_chat_controller.dart';
import 'package:dashboard/features/chat/lan_chat_page.dart';
import 'package:dashboard/features/chat/lan_chat_thread_page.dart';
import 'package:flutter/material.dart';

class LanChatPageState extends State<LanChatPage> {
  final _controller = LanChatController();
  final _endpoint = TextEditingController();
  final _device = TextEditingController(text: 'dashboard');

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final values = await _controller.store.settings();
    if (!mounted) return;
    _endpoint.text = values['endpoint'] ?? '';
    _device.text = values['device'] ?? 'dashboard';
  }

  Future<void> _connect() async {
    final endpoint = Uri.tryParse(_endpoint.text.trim());
    if (endpoint == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('服务地址格式错误')));
      return;
    }
    await _controller.connect(endpoint, _device.text.trim());
  }

  Future<void> _open(String peer) async {
    try {
      await _controller.openPeer(peer);
      if (!mounted || _controller.roster == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              LanChatThreadPage(controller: _controller, peer: peer),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打开会话失败：$error')));
      }
    } finally {
      _controller.closePeer();
    }
  }

  void _help() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('配置妙传聊天服务'),
      content: const SingleChildScrollView(
        child: Text(
          '请先部署兼容 flutter-im 的 webchat 服务，然后输入 ws://主机:8099/webchat 或 wss://安全域名/webchat。客户端会追加 /echo 路径。\n\n设备标识用于服务端区分用户。连接后选择在线用户即可发送文字；图片选择只在本机预览。\n\n请仅连接您信任的服务。ws:// 不加密；跨公网请使用 wss://。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('知道了'),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    _endpoint.dispose();
    _device.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('局域网聊天'),
        actions: [
          IconButton(
            onPressed: _help,
            tooltip: '配置帮助',
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _endpoint,
                    decoration: const InputDecoration(
                      labelText: '妙传服务地址',
                      hintText: 'ws://192.168.1.10:8099/webchat',
                    ),
                  ),
                  TextField(
                    controller: _device,
                    decoration: const InputDecoration(labelText: '设备标识（英文或数字）'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _controller.connecting ? null : _connect,
                        child: Text(
                          _controller.connecting ? '连接中…' : '连接 / 刷新用户',
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _controller.connected
                            ? _controller.disconnect
                            : null,
                        child: const Text('断开'),
                      ),
                    ],
                  ),
                  if (_controller.roster != null)
                    Text('当前用户：${_controller.roster!.user}'),
                  if (_controller.error != null)
                    Text('连接提示：${_controller.error}'),
                ],
              ),
            ),
            Expanded(
              child: _controller.roster == null
                  ? Center(
                      child: Text(
                        _controller.connected ? '等待服务端用户列表…' : '配置服务地址后连接聊天服务',
                      ),
                    )
                  : _controller.roster!.peers.isEmpty
                  ? const Center(child: Text('暂无其他在线用户'))
                  : ListView(
                      children: [
                        for (final peer in _controller.roster!.peers)
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(peer),
                            trailing: _controller.unread(peer) > 0
                                ? Badge(
                                    label: Text('${_controller.unread(peer)}'),
                                  )
                                : null,
                            onTap: () => _open(peer),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
