import 'package:dashboard/features/comic/picacomic/core/account_info_item.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';

/// Ports PicaComic's `AccountConfig`.
class AccountConfig {
  final LoginFunction? login;
  final String? loginWebsite;
  final String? registerWebsite;

  /// Clears the persisted credentials. Always present.
  final void Function() logout;
  final bool allowReLogin;
  final List<AccountInfoItem> infoItems;

  const AccountConfig({
    this.login,
    this.loginWebsite,
    this.registerWebsite,
    required this.logout,
    this.allowReLogin = true,
    this.infoItems = const [],
  });
}
