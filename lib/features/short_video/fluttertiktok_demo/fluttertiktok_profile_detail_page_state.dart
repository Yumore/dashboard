import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_app_bar.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_detail_page.dart';
import 'package:flutter/material.dart';

class FlutterTiktokProfileDetailPageState
    extends State<FlutterTiktokProfileDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back1,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          const FlutterTiktokAppBar(
            title: FlutterTiktokDemoConfig.profileDetailTitle,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.paddingOf(context).bottom,
              ),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Text(
                          FlutterTiktokDemoConfig.profileDetailSection,
                          style: FlutterTiktokPalette.smallWithOpacity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text(
                        FlutterTiktokDemoConfig.profileDetailEdit,
                        style: FlutterTiktokPalette.smallWithOpacity.copyWith(
                          color: FlutterTiktokPalette.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                for (
                  int i = 0;
                  i < FlutterTiktokDemoConfig.profileDetailTitles.length;
                  i++
                )
                  _detailRow(
                    index: i,
                    title: FlutterTiktokDemoConfig.profileDetailTitles[i],
                    value: FlutterTiktokDemoConfig.profileDetailValues[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required int index,
    required String title,
    required String value,
  }) {
    return GestureDetector(
      key: Key('fluttertiktok_profile_detail_row_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: FlutterTiktokPalette.white.withValues(alpha: 0.02),
          border: Border(
            bottom: BorderSide(
              color: FlutterTiktokPalette.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Text(title, style: FlutterTiktokPalette.normal),
            const Spacer(),
            Opacity(
              opacity: 0.6,
              child: Text(value, style: FlutterTiktokPalette.small),
            ),
          ],
        ),
      ),
    );
  }
}
