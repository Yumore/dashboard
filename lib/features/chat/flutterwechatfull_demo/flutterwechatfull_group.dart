import 'flutterwechatfull_list_tile.dart';

/// Header / rows / footer bundle used by the settings screens.
///
/// Mirrors the source `CommonGroup` model: the header and footer are grey
/// captions, the rows live inside one bordered white box.
class FlutterWechatFullGroup {
  const FlutterWechatFullGroup({
    required this.items,
    this.header,
    this.footer,
    this.headerHeight = 16.0,
    this.footerHeight = 16.0,
  });

  final List<FlutterWechatFullListTile> items;
  final String? header;
  final String? footer;
  final double headerHeight;
  final double footerHeight;
}
