import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_ad_placeholder.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_detail_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_entry.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_row.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_switch_app_bar.dart';
import 'package:flutter/material.dart';

class FlutterTiktokMessagePageState extends State<FlutterTiktokMessagePage> {
  static const int privateMessageCount = 6;

  void _openEntry(FlutterTiktokMessageEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterTiktokMessageDetailPage(
          title: entry.title,
          messageTitle: entry.messageTitle,
          messageDesc: entry.messageDesc,
          reverse: entry.reverse,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back1,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          const FlutterTiktokSwitchAppBar(index: 0, labels: <String>['消息']),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.paddingOf(context).bottom,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      for (final FlutterTiktokMessageEntry entry
                          in FlutterTiktokMessageEntry.entries)
                        Expanded(
                          child: GestureDetector(
                            key: Key(
                              'fluttertiktok_message_entry_${entry.label}',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openEntry(entry),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomCenter,
                                      colors: entry.colors,
                                      stops: const <double>[0.1, 0.8],
                                    ),
                                  ),
                                  child: Icon(
                                    entry.icon,
                                    color: FlutterTiktokPalette.white,
                                    size: FlutterTiktokPalette.iconNormal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.label,
                                  style: FlutterTiktokPalette.small,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const FlutterTiktokAdPlaceholder(),
                _sectionTitle(FlutterTiktokDemoConfig.messageSectionSystem),
                FlutterTiktokMessageRow(
                  title: '商务洽谈',
                  desc: '您收到了3个商务洽谈申请',
                  lead: ClipOval(
                    child: Container(
                      width: 40,
                      height: 40,
                      color: FlutterTiktokPalette.back2,
                      child: const Icon(
                        Icons.done_all,
                        color: FlutterTiktokPalette.orange,
                      ),
                    ),
                  ),
                ),
                FlutterTiktokMessageRow(
                  title: '系统',
                  desc: '12条未读的系统消息',
                  lead: _businessLead(),
                ),
                FlutterTiktokMessageRow(
                  title: '通知',
                  desc: '98条未读通知',
                  lead: _businessLead(),
                ),
                _sectionTitle(FlutterTiktokDemoConfig.messageSectionPrivate),
                for (int i = 0; i < privateMessageCount; i++)
                  const FlutterTiktokMessageRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: FlutterTiktokPalette.smallWithOpacity),
      ),
    );
  }

  Widget _businessLead() {
    return const SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(color: FlutterTiktokPalette.back2),
        child: Icon(Icons.business, color: FlutterTiktokPalette.orange),
      ),
    );
  }
}
