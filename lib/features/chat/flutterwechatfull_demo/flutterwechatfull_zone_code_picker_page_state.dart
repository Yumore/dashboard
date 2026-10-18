import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_zone_code.dart';
import 'flutterwechatfull_zone_code_picker_page.dart';

/// Searchable A-Z list of the 193 bundled zone codes.
class FlutterWechatFullZoneCodePickerPageState
    extends State<FlutterWechatFullZoneCodePickerPage> {
  static const double _sectionHeaderHeight = 36.0;
  static const double _rowHeight = 44.0;

  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  List<FlutterWechatFullZoneCode> get _visible {
    if (_query.isEmpty) {
      return FlutterWechatFullDemoData.zoneCodes;
    }
    return FlutterWechatFullDemoData.zoneCodes.where((
      FlutterWechatFullZoneCode code,
    ) {
      return code.name.contains(_query) ||
          code.englishName.toLowerCase().contains(_query.toLowerCase()) ||
          code.tel.contains(_query);
    }).toList();
  }

  Map<String, List<FlutterWechatFullZoneCode>> get _sections {
    final Map<String, List<FlutterWechatFullZoneCode>> sections =
        <String, List<FlutterWechatFullZoneCode>>{};
    for (final FlutterWechatFullZoneCode code in _visible) {
      sections
          .putIfAbsent(code.tag, () => <FlutterWechatFullZoneCode>[])
          .add(code);
    }
    return sections;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _jumpTo(String tag) {
    final Map<String, List<FlutterWechatFullZoneCode>> sections = _sections;
    final List<String> tags = sections.keys.toList()..sort();
    double offset = 0.0;
    for (final String key in tags) {
      if (key == tag) {
        break;
      }
      offset += _sectionHeaderHeight + sections[key]!.length * _rowHeight;
    }
    if (!_controller.hasClients) {
      return;
    }
    final double max = _controller.position.maxScrollExtent;
    _controller.animateTo(
      offset > max ? max : offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<FlutterWechatFullZoneCode>> sections = _sections;
    final List<String> tags = sections.keys.toList()..sort();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '选择国家和地区',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            controller: _controller,
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildSearchBar(),
              for (final String tag in tags) ...<Widget>[
                Container(
                  height: _sectionHeaderHeight,
                  color: const Color(0xFFF3F4F5),
                  padding: const EdgeInsets.only(left: 15.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
                for (final FlutterWechatFullZoneCode code in sections[tag]!)
                  _buildRow(code),
              ],
            ],
          ),
          Positioned(
            top: _sectionHeaderHeight + _rowHeight,
            right: 2.0,
            bottom: 8.0,
            width: 22.0,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                for (final String tag in tags)
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
      height: 36.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, size: 16.0, color: Color(0xFFB2B2B2)),
          const SizedBox(width: 4.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (String value) => setState(() => _query = value),
              style: const TextStyle(fontSize: 15.0),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '搜索',
                hintStyle: TextStyle(fontSize: 15.0, color: Color(0xFFB2B2B2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(FlutterWechatFullZoneCode code) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(code.tel),
        child: Container(
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: FlutterWechatFullStyle.divider,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  code.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: FlutterWechatFullStyle.textPrimary,
                  ),
                ),
              ),
              Text(
                '+${code.tel}',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: FlutterWechatFullStyle.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
