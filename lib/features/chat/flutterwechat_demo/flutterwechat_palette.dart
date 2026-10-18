import 'package:flutter/material.dart';

/// Colours used by flutter-wechat (source `lib/main.dart` theme and the
/// per-widget `Color(0x...)` literals), collected in one place for the port.
class FlutterWechatPalette {
  const FlutterWechatPalette._();

  /// Source `ThemeData.primaryColor`.
  static const Color appBar = Color(0xFF303030);

  /// Source `ThemeData.scaffoldBackgroundColor`.
  static const Color scaffold = Color(0xFFEBEBEB);

  /// Source `ThemeData.cardColor`; used as the popup-menu background.
  static const Color menuBackground = Color(0xFF393A3F);

  /// Selected / unselected bottom-navigation colours (source `lib/app.dart`).
  static const Color navigationSelected = Color(0xFF46C01B);
  static const Color navigationUnselected = Color(0xFF999999);

  /// Row text colours (source `lib/home/MessageItem.dart`,
  /// `lib/contacts/ContactItem.dart`, `lib/common/wechatItem.dart`).
  static const Color primaryText = Color(0xFF353535);
  static const Color secondaryText = Color(0xFFA9A9A9);
  static const Color divider = Color(0xFFD9D9D9);

  /// Pressed background of the source `ClickFeedback` wrapper.
  static const Color pressedBackground = Color(0xFFD8D8D8);

  /// Search screen (source `lib/home/search.dart`).
  static const Color searchLink = Color(0xFF1AAD19);
  static const Color searchHint = Color(0xFFB5B5B5);
  static const Color searchMic = Color(0xFFAAAAAA);

  /// Contact section bar (source `lib/contacts/contacts.dart`).
  static const Color sectionBackground = Color(0xFFE0E0E0);
  static const Color sectionText = Color(0xFF909090);

  /// Border of the Flutter UI catalogue cards (source
  /// `lib/widgets/FlutterUI.dart`).
  static const Color catalogBorder = Color(0xFF9C9C9C);

  /// Dimmed overlay behind the contact index letter (source
  /// `lib/contacts/ContactSiderList.dart`).
  static const Color indexOverlay = Color(0x60000000);
}
