import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 源工程 `LoadingWidget`：`isImage`（图片占位）用 Ripple，其余用 Wave。
class FeedbooksLoadingWidget extends StatelessWidget {
  const FeedbooksLoadingWidget({super.key, this.isImage = false});

  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.secondary;
    return Center(
      child: isImage ? SpinKitRipple(color: color) : SpinKitWave(color: color),
    );
  }
}
