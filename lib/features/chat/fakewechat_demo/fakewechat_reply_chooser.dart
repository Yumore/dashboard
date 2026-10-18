import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';

/// Deterministic replacement for the source's hard-coded isolate reply.
///
/// The source always answered `"my reply"` (`lib/server/ChatAI.dart`). Keeping
/// a chooser instead of a bare literal lets the test prove the selection rule
/// (seed + sequence modulo length) without sleeping on a timer.
class FakeWechatReplyChooser {
  const FakeWechatReplyChooser({
    this.replies = const <String>[FakeWechatDemoConfig.defaultAiReply],
    this.seed = 0,
  });

  final List<String> replies;
  final int seed;

  String replyFor(int sequence) {
    if (replies.isEmpty) {
      return FakeWechatDemoConfig.defaultAiReply;
    }
    final index = (seed + sequence) % replies.length;
    return replies[index];
  }
}
