import 'package:flutter/material.dart';

import 'flutterwechatfull_search_content.dart';

import 'flutterwechatfull_search_page.dart';

class FlutterWechatFullSearchPageState
    extends State<FlutterWechatFullSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              height: 48.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.search,
                            size: 16.0,
                            color: Color(0xFFB2B2B2),
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              style: const TextStyle(fontSize: 15.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '搜索',
                                hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xFFB2B2B2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF576B94),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: FlutterWechatFullSearchContent()),
          ],
        ),
      ),
    );
  }
}
