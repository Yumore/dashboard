import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_recorder_notice.dart';
import 'package:flutter/material.dart';

/// Port of the source `ControlPanel` (`lib/page/wechat/chat_detail_page.dart`).
///
/// It keeps the voice/keyboard toggle, text field, send button, emoji button,
/// add button and the four-entry toolkit panel. The real recorder is replaced
/// by [onRecordPressed], which the page answers with
/// [FakeWechatRecorderNotice].
class FakeWechatControlPanel extends StatelessWidget {
  const FakeWechatControlPanel({
    super.key,
    required this.inputMode,
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.toolkitVisible,
    required this.recorderUnavailable,
    required this.onToggleInputMode,
    required this.onChanged,
    required this.onSend,
    required this.onRecordPressed,
    required this.onToggleToolkit,
    required this.onToolkitTap,
  });

  final bool inputMode;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final bool toolkitVisible;
  final bool recorderUnavailable;
  final VoidCallback onToggleInputMode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onRecordPressed;
  final VoidCallback onToggleToolkit;
  final ValueChanged<String> onToolkitTap;

  static const List<({String label, IconData icon})> _tools =
      <({String label, IconData icon})>[
        (label: '相册', icon: Icons.image),
        (label: '拍摄', icon: Icons.camera_alt),
        (label: '文件', icon: Icons.attach_file),
        (label: '红包', icon: Icons.account_balance_wallet),
      ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: onToggleInputMode,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      inputMode ? Icons.keyboard_voice : Icons.keyboard,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(child: _buildInput()),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.insert_emoticon, size: 30),
                  ),
                ),
                const SizedBox(width: 4),
                canSend
                    ? SizedBox(
                        width: 62,
                        height: 30,
                        child: FilledButton(
                          onPressed: onSend,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: FakeWechatDemoConfig.toolbarGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            FakeWechatDemoConfig.sendButtonLabel,
                            maxLines: 1,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: onToggleToolkit,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.add, size: 30),
                        ),
                      ),
              ],
            ),
          ),
          if (recorderUnavailable) const FakeWechatRecorderNotice(),
          if (toolkitVisible)
            SizedBox(
              height: 260,
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 18,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
                physics: const NeverScrollableScrollPhysics(),
                children: _tools
                    .map(
                      (tool) => InkWell(
                        onTap: () => onToolkitTap(tool.label),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(tool.icon, size: 28),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tool.label,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    if (inputMode) {
      return Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          maxLines: 5,
          minLines: 1,
          textAlign: TextAlign.start,
          cursorColor: FakeWechatDemoConfig.toolbarGreen,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: null,
          onChanged: onChanged,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRecordPressed,
      child: Listener(
        onPointerDown: (details) => onRecordPressed(),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            FakeWechatDemoConfig.voiceHoldLabel,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
