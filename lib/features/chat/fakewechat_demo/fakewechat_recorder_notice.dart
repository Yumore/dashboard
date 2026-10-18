import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:flutter/material.dart';

/// Explicit unavailable state for the source's real flutter_sound recorder.
///
/// The host has no `flutter_sound` dependency, so the hold-to-record affordance
/// remains visible but never produces an audio message. This banner says so in
/// plain language instead of faking a recording.
class FakeWechatRecorderNotice extends StatelessWidget {
  const FakeWechatRecorderNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: const Row(
        children: <Widget>[
          Icon(Icons.mic_off, size: 18, color: Color(0xFFE65100)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              FakeWechatDemoConfig.recorderUnavailableMessage,
              style: TextStyle(fontSize: 13, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }
}
