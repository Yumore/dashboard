import 'dart:math' as math;

import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_contacts_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_rapid_positioning.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';

class FakeWechatContactsPageState extends State<FakeWechatContactsPage> {
  static const double _letterHeight = 30;
  static const double _friendHeight = 56;
  static const double _countHeight = 40;

  final ScrollController _controller = ScrollController();

  String? _activeLetter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpToLetter(String letter) {
    setState(() {
      _activeLetter = letter;
    });

    if (!FakeWechatSeedData.contactLetterHeaders.contains(letter)) {
      return;
    }

    double offset = 0;
    for (final Object item in FakeWechatSeedData.contactsItems) {
      if (item is String) {
        if (item == letter) {
          break;
        }
        offset += _letterHeight;
      } else if (item is FakeWechatFriend) {
        offset += _friendHeight;
      } else {
        offset += _countHeight;
      }
    }

    if (!_controller.hasClients) {
      return;
    }
    final double target = math.min(
      offset,
      _controller.position.maxScrollExtent,
    );
    _controller.jumpTo(target);
  }

  void _releaseLetter() {
    if (_activeLetter == null) {
      return;
    }
    setState(() {
      _activeLetter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          ListView.builder(
            controller: _controller,
            itemCount: FakeWechatSeedData.contactsItems.length,
            itemBuilder: (context, index) {
              final Object item = FakeWechatSeedData.contactsItems[index];
              if (item is String) {
                return Container(
                  height: _letterHeight,
                  padding: const EdgeInsets.only(left: 14, top: 10),
                  color: const Color(0x88BDBDBD),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
                );
              }
              if (item is FakeWechatFriend) {
                return Container(
                  height: _friendHeight,
                  padding: const EdgeInsets.only(left: 14, top: 4, bottom: 4),
                  child: Row(
                    children: <Widget>[
                      FakeWechatAvatar(name: item.name, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0x55BDBDBD),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                height: _countHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  '$item位联系人',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 8,
            right: 0,
            bottom: 8,
            child: FakeWechatRapidPositioning(
              activeLetter: _activeLetter,
              onChanged: _jumpToLetter,
              onReleased: _releaseLetter,
            ),
          ),
        ],
      ),
    );
  }
}
