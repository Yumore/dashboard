import 'package:flutter/material.dart';

import 'package:dashboard/app/platform/app_toast.dart';

/// `lib/pages/mine/widgets/item_layout.dart` → `ItemLayout`.
///
/// The mine screen's rows are all "tap to be told what this is": the source
/// fired a toast with the row's own title and navigated nowhere.
class EyepetizerFlutterItemLayout extends StatelessWidget {
  const EyepetizerFlutterItemLayout({
    super.key,
    required this.title,
    this.color,
  });

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppToast.show(msg: title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 15, color: color ?? Colors.black87),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
