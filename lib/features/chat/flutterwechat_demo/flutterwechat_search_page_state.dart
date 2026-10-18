import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_config.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_search_page.dart';
import 'package:flutter/material.dart';

/// State of the ported search screen.
///
/// The source only laid the screen out: typing had an empty `onChanged` and
/// every green label had an empty tap handler, so the port keeps them inert.
class FlutterWechatSearchPageState extends State<FlutterWechatSearchPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _suggestion(String text) {
    return FlutterWechatPressable(
      isFeed: false,
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.0,
          color: FlutterWechatPalette.searchLink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      body: Container(
        margin: const EdgeInsets.only(top: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                FlutterWechatPressable(
                  isFeed: false,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 45.0,
                    margin: const EdgeInsets.only(left: 12.0, right: 10.0),
                    child: const Icon(Icons.chevron_left, color: Colors.black),
                  ),
                ),
                Container(
                  height: 45.0,
                  margin: const EdgeInsets.only(left: 50.0, right: 10.0),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.green),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          autofocus: true,
                          onChanged: (text) {},
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          decoration: const InputDecoration(
                            hintText: FlutterWechatDemoConfig.searchHint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: const Icon(
                          Icons.mic,
                          color: FlutterWechatPalette.searchMic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              child: const Text(
                FlutterWechatDemoConfig.searchPlaceholder,
                style: TextStyle(
                  fontSize: 16.0,
                  color: FlutterWechatPalette.searchHint,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (final text
                      in FlutterWechatDemoConfig.searchSuggestionsTop)
                    _suggestion(text),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (final text
                      in FlutterWechatDemoConfig.searchSuggestionsBottom)
                    _suggestion(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
