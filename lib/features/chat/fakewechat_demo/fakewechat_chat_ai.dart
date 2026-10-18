import 'dart:async';

import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_reply_chooser.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';

/// Plain-Dart port of the source `lib/server/ChatAI.dart` reply loop.
///
/// Source behaviour: an in-process `Isolate` starts a recursive
/// `Future.delayed(Duration(seconds: 10))` that emits the literal `"my reply"`
/// forever, and the chat page adds every emission as
/// `Message(0, text: message, sender: FRIENDS[0])`. The port keeps the cadence,
/// the literal reply and the replier, but uses a cancellable [Timer] instead of
/// an isolate. Cancelling on dispose also fixes the source bug where
/// `listenMessage` was registered again on every rebuild.
class FakeWechatChatAi {
  FakeWechatChatAi({
    this.replyInterval = FakeWechatDemoConfig.aiReplyInterval,
    this.chooser = const FakeWechatReplyChooser(),
    FakeWechatFriend? replier,
  }) : replier = replier ?? FakeWechatSeedData.friends[0];

  final Duration replyInterval;
  final FakeWechatReplyChooser chooser;
  final FakeWechatFriend replier;

  Timer? _timer;
  int _sequence = 0;

  bool get isRunning => _timer != null;
  int get sequence => _sequence;

  /// Starts emitting replies. Calling twice replaces the previous loop, which
  /// is the safe equivalent of the source's isolate leak fix.
  void start(void Function(String reply) onReply) {
    stop();
    _sequence = 0;
    _timer = Timer.periodic(replyInterval, (timer) {
      onReply(chooser.replyFor(_sequence));
      _sequence++;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
  }
}
