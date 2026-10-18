import 'package:flutter/material.dart';

/// 源工程 `DescriptionTextWidget`：超过 300 字先截断，`show more` /
/// `show less` 切换；文本里的字面 `\n`、`\r`、`\'` 在这里做还原。
class FeedbooksDescriptionText extends StatefulWidget {
  const FeedbooksDescriptionText({super.key, required this.text});

  final String text;

  @override
  State<FeedbooksDescriptionText> createState() =>
      _FeedbooksDescriptionTextState();
}

class _FeedbooksDescriptionTextState extends State<FeedbooksDescriptionText> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _splitText();
  }

  @override
  void didUpdateWidget(covariant FeedbooksDescriptionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _splitText();
    }
  }

  void _splitText() {
    if (widget.text.length > 300) {
      firstHalf = widget.text.substring(0, 300);
      secondHalf = widget.text.substring(300, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: 16.0,
      color: Theme.of(context).textTheme.bodySmall?.color,
    );
    return secondHalf.isEmpty
        ? Text(
            (flag ? firstHalf : (firstHalf + secondHalf))
                .replaceAll(r'\n', '\n')
                .replaceAll(r'\r', '')
                .replaceAll(r"\'", "'"),
            style: style,
          )
        : Column(
            children: <Widget>[
              Text(
                (flag ? ('$firstHalf...') : (firstHalf + secondHalf))
                    .replaceAll(r'\n', '\n\n')
                    .replaceAll(r'\r', '')
                    .replaceAll(r"\'", "'"),
                style: style,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    flag = !flag;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      flag ? 'show more' : 'show less',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
