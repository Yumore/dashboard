import 'package:flutter/material.dart';

/// 源工程 `MyErrorWidget`：同一套文案 + `TRY AGAIN` 按钮，
/// 只区分“网络问题”和“页面加载失败”两种提示。
class FeedbooksErrorWidget extends StatelessWidget {
  const FeedbooksErrorWidget({
    super.key,
    required this.refreshCallBack,
    this.isConnection = false,
  });

  final VoidCallback refreshCallBack;
  final bool isConnection;

  String get errorText {
    if (isConnection) {
      return 'There is a problem with your internet connection. '
          '\nPlease try again.';
    }
    return 'Could not load this page. \nPlease try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('😔', style: TextStyle(fontSize: 60.0)),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              errorText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: refreshCallBack,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text(
              'TRY AGAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
