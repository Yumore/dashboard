import 'package:flutter/material.dart';

/// Colours copied from the source `lib/constant/style.dart`.
///
/// The source uses the same palette for every screen, so the port keeps one
/// class instead of scattering hex literals through the widgets.
class FlutterWechatFullStyle {
  const FlutterWechatFullStyle._();

  /// `Style.pTintColor` — WeChat green used by selected tabs and buttons.
  static const Color primary = Color(0xFF07C160);

  /// `Style.sTintColor` — darker green used for the 登陆 button label.
  static const Color primaryDark = Color(0xFF06AD56);

  /// `Style.pDividerColor` — rgba(0, 0, 0, 0.1).
  static const Color divider = Color(0x1A000000);

  /// `Style.pTextColor` — rgba(0, 0, 0, 0.9).
  static const Color textPrimary = Color(0xE6000000);

  /// `Style.sTextColor` — rgba(0, 0, 0, 0.5).
  static const Color textSecondary = Color(0x80000000);

  /// `Style.mTextColor` — rgba(0, 0, 0, 0.3).
  static const Color textHint = Color(0x4D000000);

  /// `Style.pBackgroundColor`.
  static const Color background = Color(0xFFEDEDED);

  /// `Style.pTextWarnColor` — the red used by 删除 / 退出登录 rows.
  static const Color warning = Color(0xFFFA5151);

  /// `Style.pTextBlueColor` — links and the 发消息 row.
  static const Color link = Color(0xFF576B95);

  /// Pressed state of a common cell (`0xFFE5E5E5` in the source).
  static const Color cellHighlight = Color(0xFFE5E5E5);

  /// Hairline drawn above and below a common group.
  static const Color groupBorder = Color(0xFFD8D8D8);

  /// Divider between two rows of a common group.
  static const Color rowDivider = Color(0xFFE6E6E6);

  /// Background of an A-Z section header.
  static const Color sectionHeader = Color(0xFFF3F4F5);

  /// Text of the search category row (`0xFF576B94`).
  static const Color searchCategory = Color(0xFF576B94);

  /// iOS-style horizontal divider inside the conversation list.
  static const Color listDivider = Color(0xFFE6E6E6);
}
