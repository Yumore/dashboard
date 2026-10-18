import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact_header.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact_item.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contacts_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_config.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:flutter/material.dart';

/// State of the ported contacts tab.
///
/// The source measured its header/item/section heights at runtime
/// (`lib/contacts/ContactSiderList.dart`); the port knows them from the layout
/// (header 3 × 52, section 32, item 52) and uses the same jump formula.
class FlutterWechatContactsPageState extends State<FlutterWechatContactsPage> {
  static const double _itemHeight = 52.0;
  static const double _sectionHeight = 32.0;
  static const double _headerHeight = 3 * 52.0;
  static const double _siderBarWidth = 32.0;

  final ScrollController _scrollController = ScrollController();

  Color _pressColor = Colors.transparent;
  bool _showCenterIndex = true;
  int _siderBarIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasSection(int index) {
    if (index == 0) {
      return true;
    }
    return flutterWechatContacts[index].seationKey !=
        flutterWechatContacts[index - 1].seationKey;
  }

  /// Jumps to the first contact whose section matches the pressed index letter.
  ///
  /// Mirrors `_scrollToPosition` in the source: `↑`/`☆` go to the top,
  /// unknown letters do nothing, and the target offset is clamped to the last
  /// scrollable position.
  void _jumpToKey(int rawIndex) {
    final index = rawIndex.clamp(
      0,
      FlutterWechatDemoConfig.contactIndexKeys.length - 1,
    );
    setState(() {
      _siderBarIndex = index;
    });
    final key = FlutterWechatDemoConfig.contactIndexKeys[index];
    if (key == '↑' || key == '☆') {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
      return;
    }
    final listIndex = flutterWechatContacts.indexWhere(
      (contact) => contact.seationKey == key,
    );
    if (listIndex == -1) {
      return;
    }
    var sectionSum = 0;
    for (var i = 0; i < listIndex; i++) {
      if (_hasSection(i)) {
        sectionSum++;
      }
    }
    var offset =
        _headerHeight + sectionSum * _sectionHeight + listIndex * _itemHeight;
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (offset > maxScrollExtent) {
        offset = maxScrollExtent;
      }
      _scrollController.jumpTo(offset);
    }
  }

  void _handleIndexPointer(
    double localY,
    double keyHeight, {
    required bool drag,
  }) {
    if (keyHeight <= 0.0) {
      return;
    }
    final index = (localY / keyHeight).floor();
    if (drag) {
      setState(() {
        _showCenterIndex = false;
        _pressColor = Colors.grey;
      });
    } else {
      setState(() {
        _pressColor = Colors.grey;
      });
    }
    _jumpToKey(index);
  }

  void _endIndexPointer() {
    setState(() {
      _showCenterIndex = true;
      _pressColor = Colors.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final keyHeight =
              constraints.maxHeight /
              FlutterWechatDemoConfig.contactIndexKeys.length;
          return Stack(
            children: <Widget>[
              ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: flutterWechatContacts.length,
                itemBuilder: (context, index) {
                  final showSection = _hasSection(index);
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: <Widget>[
                        if (index == 0) const FlutterWechatContactHeader(),
                        if (showSection)
                          Container(
                            height: _sectionHeight,
                            padding: const EdgeInsets.only(left: 14.0),
                            color: FlutterWechatPalette.sectionBackground,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              flutterWechatContacts[index].seationKey,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: FlutterWechatPalette.sectionText,
                              ),
                            ),
                          ),
                        FlutterWechatContactItem(
                          item: flutterWechatContacts[index],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 0.0,
                bottom: 0.0,
                right: 0.0,
                width: _siderBarWidth,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _handleIndexPointer(
                      details.localPosition.dy,
                      keyHeight,
                      drag: false,
                    );
                  },
                  onTapUp: (details) => _endIndexPointer(),
                  onTapCancel: _endIndexPointer,
                  onVerticalDragStart: (details) {
                    _handleIndexPointer(
                      details.localPosition.dy,
                      keyHeight,
                      drag: true,
                    );
                  },
                  onVerticalDragUpdate: (details) {
                    _handleIndexPointer(
                      details.localPosition.dy,
                      keyHeight,
                      drag: true,
                    );
                  },
                  onVerticalDragEnd: (details) => _endIndexPointer(),
                  onVerticalDragCancel: _endIndexPointer,
                  child: Container(
                    color: _pressColor,
                    child: Column(
                      children: <Widget>[
                        for (final key
                            in FlutterWechatDemoConfig.contactIndexKeys)
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(key),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: _showCenterIndex,
                child: Center(
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: const BoxDecoration(
                      color: FlutterWechatPalette.indexOverlay,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Center(
                      child: Text(
                        FlutterWechatDemoConfig
                            .contactIndexKeys[_siderBarIndex],
                        style: const TextStyle(
                          fontSize: 48.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
