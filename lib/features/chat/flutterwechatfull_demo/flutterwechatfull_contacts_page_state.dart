import 'package:flutter/material.dart';

import 'flutterwechatfull_add_friend_page.dart';
import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_info_page.dart';
import 'flutterwechatfull_contacts_page.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_search_page.dart';
import 'flutterwechatfull_slidable.dart';
import 'flutterwechatfull_slidable_action.dart';
import 'flutterwechatfull_style.dart';

/// Mirrors `ContactsPage`: search bar, the four fixed rows, the A-Z contact
/// list with its right-hand index bar, and the trailing 联系人 count.
class FlutterWechatFullContactsPageState
    extends State<FlutterWechatFullContactsPage> {
  static const double _sectionHeaderHeight = 36.0;
  static const double _rowHeight = 56.0;

  final ScrollController _scrollController = ScrollController();

  late final Map<String, List<FlutterWechatFullContact>> _sections =
      _buildSections();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, List<FlutterWechatFullContact>> _buildSections() {
    final Map<String, List<FlutterWechatFullContact>> sections =
        <String, List<FlutterWechatFullContact>>{};
    for (final FlutterWechatFullContact contact
        in FlutterWechatFullDemoData.contacts) {
      sections
          .putIfAbsent(contact.tag, () => <FlutterWechatFullContact>[])
          .add(contact);
    }
    final List<String> tags = sections.keys.toList()
      ..sort((String a, String b) {
        if (a == '#') {
          return 1;
        }
        if (b == '#') {
          return -1;
        }
        return a.compareTo(b);
      });
    return <String, List<FlutterWechatFullContact>>{
      for (final String tag in tags) tag: sections[tag]!,
    };
  }

  double get _listTopOffset => 52.0 + 4 * _rowHeight;

  void _jumpTo(String tag) {
    double offset = _listTopOffset;
    for (final MapEntry<String, List<FlutterWechatFullContact>> entry
        in _sections.entries) {
      if (entry.key == tag) {
        break;
      }
      offset += _sectionHeaderHeight + entry.value.length * _rowHeight;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final double max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset > max ? max : offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _openSearch() {
    // The source opens `SearchContent` as an in-place overlay; a zero-duration
    // route reproduces the same look without the push transition.
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => const FlutterWechatFullSearchPage(),
      ),
    );
  }

  void _openAddFriend() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullAddFriendPage(),
      ),
    );
  }

  void _openContact(FlutterWechatFullContact contact) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FlutterWechatFullContactInfoPage(contact: contact),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '通讯录',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: _openAddFriend,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.contactsAdd,
                width: 24.0,
                height: 24.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildSearchBar(),
              ..._buildFixedRows(),
              for (final MapEntry<String, List<FlutterWechatFullContact>> entry
                  in _sections.entries) ...<Widget>[
                _buildSectionHeader(entry.key),
                for (final FlutterWechatFullContact contact in entry.value)
                  _buildContactRow(contact),
              ],
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: Text(
                  '${FlutterWechatFullDemoData.contacts.length}位联系人',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: FlutterWechatFullStyle.textHint,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: _listTopOffset + 8.0,
            right: 2.0,
            bottom: 8.0,
            child: _buildIndexBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openSearch,
      child: Container(
        height: 36.0,
        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.search, size: 16.0, color: Color(0xFFB2B2B2)),
              SizedBox(width: 4.0),
              Text(
                '搜索',
                style: TextStyle(fontSize: 14.0, color: Color(0xFFB2B2B2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFixedRows() {
    const List<(String, String)> rows = <(String, String)>[
      ('新的朋友', FlutterWechatFullImages.newFriends),
      ('群聊', FlutterWechatFullImages.groupChat),
      ('标签', FlutterWechatFullImages.contactTag),
      ('公众号', FlutterWechatFullImages.officialAccount),
    ];
    return <Widget>[
      for (int index = 0; index < rows.length; index++) ...<Widget>[
        SizedBox(
          height: _rowHeight,
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    FlutterWechatFullLocalImage(
                      path: rows[index].$2,
                      width: 36.0,
                      height: 36.0,
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      rows[index].$1,
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: FlutterWechatFullStyle.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (index != rows.length - 1)
          const Divider(
            height: 0.5,
            indent: 68.0,
            color: FlutterWechatFullStyle.rowDivider,
          ),
      ],
    ];
  }

  Widget _buildSectionHeader(String tag) {
    return Container(
      height: _sectionHeaderHeight,
      color: const Color(0xFFF3F4F5),
      padding: const EdgeInsets.only(left: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        style: const TextStyle(fontSize: 14.0, color: Color(0xFF777777)),
      ),
    );
  }

  Widget _buildContactRow(FlutterWechatFullContact contact) {
    return FlutterWechatFullSlidable(
      onTap: () => _openContact(contact),
      actions: const <FlutterWechatFullSlidableAction>[
        FlutterWechatFullSlidableAction(label: '备注', color: Color(0xFFC7C7CB)),
      ],
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: _rowHeight,
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: FlutterWechatFullRemoteImage(
                url: contact.avatarUrl,
                width: 40.0,
                height: 40.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                contact.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexBar() {
    return Container(
      width: 24.0,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: _openSearch,
            child: const SizedBox(
              height: 16.0,
              child: Icon(Icons.search, size: 12.0, color: Color(0xFF808080)),
            ),
          ),
          for (final String tag in _sections.keys)
            GestureDetector(
              onTap: () => _jumpTo(tag),
              child: SizedBox(
                height: 14.0,
                child: Center(
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 9.0,
                      color: Color(0xFF808080),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
