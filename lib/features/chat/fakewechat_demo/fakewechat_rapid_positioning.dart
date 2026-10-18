import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:flutter/material.dart';

/// Simplified port of `lib/rapid_positioning.dart`.
///
/// The source implements a custom `RenderObject` with a gesture recognizer.
/// For the static demo a plain vertical hit area is enough: it maps the touch
/// position to a letter, highlights it while held, and asks the parent to
/// scroll. The visible letter set matches the source `DEFAULT_DATA`
/// (`↑`, `★`, A-Z, `#`).
class FakeWechatRapidPositioning extends StatelessWidget {
  const FakeWechatRapidPositioning({
    super.key,
    required this.activeLetter,
    required this.onChanged,
    required this.onReleased,
  });

  static const List<String> letters = <String>[
    '↑',
    '★',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#',
  ];

  final String? activeLetter;
  final ValueChanged<String> onChanged;
  final VoidCallback onReleased;

  void _report(Offset localPosition, double height) {
    if (height <= 0) {
      return;
    }
    final double step = height / letters.length;
    final int index = (localPosition.dy / step).floor().clamp(
      0,
      letters.length - 1,
    );
    onChanged(letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _report(details.localPosition, constraints.maxHeight),
          onTapUp: (details) => onReleased(),
          onVerticalDragStart: (details) =>
              _report(details.localPosition, constraints.maxHeight),
          onVerticalDragUpdate: (details) =>
              _report(details.localPosition, constraints.maxHeight),
          onVerticalDragEnd: (details) => onReleased(),
          child: Container(
            width: 22,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: letters
                  .map(
                    (letter) => Text(
                      letter,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1,
                        color: letter == activeLetter
                            ? FakeWechatDemoConfig.wechatGreen
                            : Colors.black,
                        fontWeight: letter == activeLetter
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }
}
