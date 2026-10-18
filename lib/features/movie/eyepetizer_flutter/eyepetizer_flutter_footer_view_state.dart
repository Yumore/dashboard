import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_footer_view.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_load_status.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterFooterView].
class EyepetizerFlutterFooterViewState
    extends State<EyepetizerFlutterFooterView> {
  /// `FooterViewState.getLoadStatusText`, verbatim strings.
  static String labelFor(EyepetizerFlutterLoadStatus? loadStatus) {
    switch (loadStatus) {
      case EyepetizerFlutterLoadStatus.loading:
        return '加载中...';
      case EyepetizerFlutterLoadStatus.completed:
        return '加载完成';
      case EyepetizerFlutterLoadStatus.init:
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.loadStatus == EyepetizerFlutterLoadStatus.loading
          ? 1.0
          : 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              labelFor(widget.loadStatus),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
