import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_message.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:dashboard/app/platform/app_local_image.dart';
import 'package:flutter/material.dart';

/// Port of `MessageBox` from the source `lib/page/wechat/chat_detail_page.dart`.
///
/// Source bubble rules preserved here:
/// * max text width 200, padding 7, user green / friend white;
/// * user messages are laid out right-to-left so the avatar sits on the right;
/// * sound bubble width grows with duration (clamped to 0.3..1.0);
/// * image messages are shown at 100 px wide.
class FakeWechatMessageBubble extends StatelessWidget {
  const FakeWechatMessageBubble({
    super.key,
    required this.message,
    this.onTapSound,
  });

  final FakeWechatMessage message;
  final VoidCallback? onTapSound;

  bool get _isUser => identical(message.sender, FakeWechatSeedData.user);

  @override
  Widget build(BuildContext context) {
    final String senderName = message.sender?.name ?? '?';
    return Directionality(
      textDirection: _isUser ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FakeWechatAvatar(name: senderName, size: 36, borderRadius: 3),
          const SizedBox(width: 10),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case FakeWechatMessage.textType:
        return _buildTextBox();
      case FakeWechatMessage.imageType:
        return _buildImageBox();
      case FakeWechatMessage.soundType:
        return _buildSoundBox();
      case FakeWechatMessage.redPacketType:
        return _buildRedPacketBox();
      default:
        return const Text('暂不支持该消息类型!');
    }
  }

  Widget _buildTextBox() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: _isUser
            ? FakeWechatDemoConfig.bubbleGreen
            : const Color(0xFFFFFFFF),
      ),
      child: Text(
        message.text ?? '',
        softWrap: true,
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildImageBox() {
    final String? path = message.filePath;
    if (path == null || path.isEmpty) {
      return const Text('暂不支持该消息类型!');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image(
        image: AppLocalImage.provider(path),
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 100,
          height: 100,
          color: const Color(0xFFE0E0E0),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSoundBox() {
    final int milliseconds = message.duration ?? 0;
    final double factor = (milliseconds / 60000).clamp(0.3, 1.0).toDouble();
    return Flexible(
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: factor,
        child: GestureDetector(
          onTap: onTapSound,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _isUser
                  ? FakeWechatDemoConfig.bubbleGreen
                  : const Color(0xFFFFFFFF),
            ),
            child: Text(
              "${milliseconds ~/ 1000}'",
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRedPacketBox() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3A03B),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('红包', style: TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
