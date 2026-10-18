import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_ad_placeholder.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_search_page.dart';
import 'package:flutter/material.dart';

class FlutterTiktokSearchPageState extends State<FlutterTiktokSearchPage> {
  static const int hotSearchRowCount = 5;

  void _pop() {
    if (widget.onPop != null) {
      widget.onPop!();
      return;
    }
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back1,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Container(
            color: FlutterTiktokPalette.back2,
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.fullscreen,
                    size: FlutterTiktokPalette.iconNormal,
                    color: FlutterTiktokPalette.white,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.only(left: 12, right: 20),
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: FlutterTiktokPalette.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Opacity(
                      opacity: 0.3,
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.search,
                            size: 20,
                            color: FlutterTiktokPalette.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              FlutterTiktokDemoConfig.searchHint,
                              style: FlutterTiktokPalette.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  key: const Key('fluttertiktok_search_cancel'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _pop,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      FlutterTiktokDemoConfig.searchCancel,
                      style: FlutterTiktokPalette.normal.copyWith(
                        color: FlutterTiktokPalette.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (int i = 0; i < hotSearchRowCount; i++) _hotSearchRow(i),
                Opacity(
                  opacity: 0.6,
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    child: Text(
                      FlutterTiktokDemoConfig.searchHistoryTitle,
                      style: FlutterTiktokPalette.normal,
                    ),
                  ),
                ),
                const FlutterTiktokAdPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotSearchRow(int index) {
    return Padding(
      key: Key('fluttertiktok_search_hot_$index'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.timelapse,
            size: 20,
            color: FlutterTiktokPalette.white,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                FlutterTiktokDemoConfig.searchHotTitle,
                style: FlutterTiktokPalette.normal,
              ),
            ),
          ),
          const Icon(Icons.clear, size: 20, color: FlutterTiktokPalette.white),
        ],
      ),
    );
  }
}
