import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_app_bar.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_detail_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_row.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

class FlutterTiktokMessageDetailPageState
    extends State<FlutterTiktokMessageDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back1,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          FlutterTiktokAppBar(title: widget.title),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: FlutterTiktokMessageDetailPage.rowCount,
              itemBuilder: (_, _) => FlutterTiktokMessageRow(
                title: widget.messageTitle,
                desc: widget.messageDesc,
                reverse: widget.reverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
