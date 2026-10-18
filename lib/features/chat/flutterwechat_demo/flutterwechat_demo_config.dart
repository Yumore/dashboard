/// Text and sample data values shared by the ported flutter-wechat screens.
///
/// Every value is copied from the source; nothing here is invented.
class FlutterWechatDemoConfig {
  const FlutterWechatDemoConfig._();

  /// Source `lib/app.dart` AppBar title.
  static const String appTitle = '微信';

  /// Source `lib/app.dart` bottom-navigation labels, in order.
  static const List<String> tabTitles = <String>['首页', '通讯录', '发现', '我的'];

  /// Source `lib/home/search.dart` text field hint.
  static const String searchHint = '搜索';

  /// Source `lib/home/search.dart` empty-state line.
  static const String searchPlaceholder = '搜索指定文章';

  /// Source `lib/home/search.dart` green category labels, first and second row.
  static const List<String> searchSuggestionsTop = <String>['朋友圈', '文章', '公众号'];
  static const List<String> searchSuggestionsBottom = <String>[
    '小说',
    '音乐',
    '表情',
  ];

  /// Source `lib/me/me.dart` profile header.
  static const String profileAvatarUrl =
      'http://img5.duitang.com/uploads/item/201504/17/20150417H5529_JuTGY.jpeg';
  static const String profileName = 'Herbie';
  static const String profileWechatId = '微信号：NMDFCKDDFY';

  /// Source `lib/contacts/ContactItem.dart` fallback for contacts whose
  /// `avatarUrl` is the empty string.
  static const String contactFallbackAvatarUrl =
      'http://img5.dwstatic.com/lol/1605/327187369677/1463232469572.jpeg';

  /// Source `lib/contacts/ContactSiderList.dart` index-bar keys.
  static const List<String> contactIndexKeys = <String>[
    '↑',
    '☆',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#',
  ];
}
