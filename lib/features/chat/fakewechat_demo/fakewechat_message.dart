import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';

/// Port of `Message` from the source `lib/entities.dart`.
///
/// Source types: 0 text, 1 image, 2 sound, 3 red packet.
class FakeWechatMessage {
  const FakeWechatMessage({
    required this.type,
    this.sender,
    this.receiver,
    this.filePath,
    this.text,
    this.url,
    this.duration,
    this.timestamp,
  });

  static const int textType = 0;
  static const int imageType = 1;
  static const int soundType = 2;
  static const int redPacketType = 3;

  final int type;
  final FakeWechatFriend? sender;
  final FakeWechatFriend? receiver;

  /// Local image path. The source stored a `File`; a path keeps the model
  /// serialisable and testable without touching the filesystem.
  final String? filePath;
  final String? text;
  final String? url;

  /// Milliseconds, matching the source recorder disposition stream.
  final int? duration;
  final num? timestamp;

  bool get isText => type == textType;
  bool get isImage => type == imageType;
  bool get isSound => type == soundType;
  bool get isRedPacket => type == redPacketType;
}
