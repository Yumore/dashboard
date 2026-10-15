import 'package:dashboard/features/chat/lan_chat_thread_page.dart';
import 'package:dashboard/features/chat/chat_image_selection.dart';
import 'package:dashboard/features/chat/chat_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LanChatThreadPageState extends State<LanChatThreadPage> {
  final _input = TextEditingController();
  bool _sending = false;
  bool _selectingImage = false;

  Future<void> _selectImage() async {
    if (_selectingImage) return;
    setState(() => _selectingImage = true);
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('本机预览，不会发送图片')),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('相机拍摄'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('照片库'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null || !mounted) return;
      final bytes = await ChatImageSelection().select(source);
      if (bytes == null || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ChatImagePreview(bytes: bytes)),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选图失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _selectingImage = false);
    }
  }

  Future<void> _send() async {
    final text = _input.text;
    if (_sending || text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.controller.send(widget.peer, text);
      if (mounted) _input.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发送失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除本机聊天记录？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.controller.clearPeer(widget.peer);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清除失败：$error')));
        }
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peer),
        actions: [
          IconButton(
            onPressed: _clear,
            tooltip: '清除本机记录',
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final messages = widget.controller.messages(widget.peer);
          return Column(
            children: [
              if (!widget.controller.connected) const Text('连接已断开，请返回用户列表重新连接'),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return Align(
                      alignment: message.sender == widget.peer
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(message.text),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '本机选图预览',
                      onPressed: _selectingImage ? null : _selectImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        decoration: const InputDecoration(hintText: '输入消息'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed: _sending || !widget.controller.connected
                          ? null
                          : _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
