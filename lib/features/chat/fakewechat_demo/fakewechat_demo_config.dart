import 'package:flutter/material.dart';

/// Constants carried over from the `fake_wechat` static demo.
///
/// Values are kept verbatim where the source exposed them as literals, so the
/// port can be compared against
/// `/Users/nathaniel/workspace/Flutter/fake_wechat` file by file.
class FakeWechatDemoConfig {
  const FakeWechatDemoConfig._();

  static const String appTitle = 'WeChat';

  /// Source `lib/page/wechat/message_page.dart` hard-codes this literal even
  /// though the seeded unread badges add up to 123. Both values are preserved
  /// and asserted by the demo test.
  static const String chatHeaderTitle = '微信(130)';
  static const int headerUnreadLiteral = 130;

  static const String subscriptionChatName = '订阅号消息';
  static const String noRecentMessage = '暂无最近消息';

  /// The source only has three tabs (聊天/联系人/发现). The host module entry
  /// asks for a "me" tab as well, so the port adds a fourth tab built from the
  /// source's `USER` record. See [meTabNote].
  static const List<String> tabLabels = <String>['聊天', '联系人', '发现', '我'];
  static const String meTabNote =
      '源工程底部导航只有“聊天 / 联系人 / 发现”三栏；本页按宿主演示入口补齐，'
      '内容全部来自源数据中的 USER。';

  static const String voiceHoldLabel = '按住 说话';
  static const String voiceReleaseLabel = '松开 结束';
  static const String sendButtonLabel = '发 送';

  /// The source recorder is real flutter_sound capture. The host has no
  /// flutter_sound dependency, so the affordance stays visible and reports an
  /// explicit unavailable state instead of pretending to record.
  static const String recorderUnavailableMessage = '录音不可用（宿主缺少 flutter_sound）';

  static const String defaultAiReply = 'my reply';
  static const Duration aiReplyInterval = Duration(seconds: 10);

  static const String miniProgramTitle = '小程序';
  static const String miniProgramSearchHint = '搜索小程序';
  static const String recentUsedLabel = '最近使用';
  static const String myMiniProgramsLabel = '我的小程序';

  static const String momentsTitle = '朋友圈';
  static const String momentsCoverSubtitle = '廖布斯 / 我是一个好人';
  static const String momentsTimeLabel = '10分钟前';
  static const String profileSignature = '我是一个好人';

  static const String audioUnavailableMessage = '音频播放不可用（宿主未迁移播放器）';
  static const String externalPageUnavailableMessage = '该小程序页面未迁入静态演示';

  static const Color wechatGreen = Color(0xFF58BF6B);
  static const Color toolbarGreen = Color(0xFF57BD69);
  static const Color bubbleGreen = Color(0xFFA9E87A);
  static const Color headerYellow = Color(0xFFEDED17);
  static const Color pageBackground = Color(0xFFF1F1F1);
  static const Color miniProgramBackground = Color(0xFF424058);
  static const Color unreadRed = Color(0xFFE53935);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFF999999);
}
