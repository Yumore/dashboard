/// Every image bundled with the ported demo, keyed by its source file name.
///
/// Source: `images/*.png` in flutter-wechat. The files were copied byte for
/// byte into `assets/flutterwechat_demo/`; only the directory changed.
///
/// `pubspec.yaml` must register `- assets/flutterwechat_demo/` for these
/// paths to resolve at runtime.
class FlutterWechatAvailableImages {
  const FlutterWechatAvailableImages._();

  static const String assetDirectory = 'assets/flutterwechat_demo/';

  // Bottom navigation icons (source `lib/app.dart`).
  /// 微信 tab, pressed
  static const String tabWeixinPressed = '${assetDirectory}weixin_pressed.png';

  /// 微信 tab, normal
  static const String tabWeixinNormal = '${assetDirectory}weixin_normal.png';

  /// 通讯录 tab, pressed
  static const String tabContactListPressed =
      '${assetDirectory}contact_list_pressed.png';

  /// 通讯录 tab, normal
  static const String tabContactListNormal =
      '${assetDirectory}contact_list_normal.png';

  /// 发现 tab, pressed
  static const String tabFindPressed = '${assetDirectory}find_pressed.png';

  /// 发现 tab, normal
  static const String tabFindNormal = '${assetDirectory}find_normal.png';

  /// 我的 tab, pressed
  static const String tabProfilePressed =
      '${assetDirectory}profile_pressed.png';

  /// 我的 tab, normal
  static const String tabProfileNormal = '${assetDirectory}profile_normal.png';

  // App bar overflow menu (source `lib/app.dart`).
  /// 发起群聊
  static const String menuGroup = '${assetDirectory}icon_menu_group.png';

  /// 添加朋友
  static const String menuAddFriend =
      '${assetDirectory}icon_menu_addfriend.png';

  /// 扫一扫
  static const String menuScan = '${assetDirectory}icon_menu_sao.png';

  // Contacts header (source `lib/contacts/ContactHeader.dart`).
  /// 新的朋友
  static const String contactAddFriend = '${assetDirectory}icon_addfriend.png';

  /// 群聊
  static const String contactGroupChat = '${assetDirectory}icon_qunliao.png';

  /// 公众号
  static const String contactPublicAccount = '${assetDirectory}icon_public.png';

  // Discover rows (source `lib/found/found.dart`).
  /// 朋友圈
  static const String discoverMoments = '${assetDirectory}v2.png';

  /// 扫一扫
  static const String discoverScan = '${assetDirectory}icon_de_saoyisao.png';

  /// 摇一摇
  static const String discoverShake = '${assetDirectory}icon_de_yao.png';

  /// 看一看
  static const String discoverTopStories = '${assetDirectory}icon_k.png';

  /// 搜一搜
  static const String discoverSearch = '${assetDirectory}icon_s.png';

  /// 附近的人
  static const String discoverNearby = '${assetDirectory}icon_de_nearby.png';

  /// 漂流瓶
  static const String discoverBottle = '${assetDirectory}icon_de_ping.png';

  /// 购物
  static const String discoverShopping = '${assetDirectory}icon_de_shop.png';

  /// 游戏
  static const String discoverGames = '${assetDirectory}ahl.png';

  /// 小程序
  static const String discoverMiniPrograms = '${assetDirectory}icon_link.png';

  // Profile rows (source `lib/me/me.dart`).
  /// row chevron
  static const String meArrow = '${assetDirectory}ad6.png';

  /// 钱包
  static const String meWallet = '${assetDirectory}icon_me_money.png';

  /// 收藏
  static const String meFavorites = '${assetDirectory}icon_me_collect.png';

  /// 相册
  static const String meAlbum = '${assetDirectory}icon_me_photo.png';

  /// 卡包
  static const String meCards = '${assetDirectory}icon_me_card.png';

  /// 表情
  static const String meStickers = '${assetDirectory}icon_me_smail.png';

  /// 设置
  static const String meSettings = '${assetDirectory}icon_me_setting.png';

  // Widget catalogue images (source `lib/widgets/WeigetData.dart`).
  /// Scaffold
  static const String catalogScaffold = '${assetDirectory}scaffold.png';

  /// Appbar
  static const String catalogAppbar = '${assetDirectory}appbar.png';

  /// BottomNavigationBar
  static const String catalogBottomNavigationBar =
      '${assetDirectory}BottomNavigationBar.png';

  /// TabBar
  static const String catalogTabbar = '${assetDirectory}tabbar.png';

  /// TabBarView
  static const String catalogTabBarView = '${assetDirectory}TabBarView.png';

  /// MaterialApp
  static const String catalogMaterialApp = '${assetDirectory}MaterialApp.png';

  /// FlutterLogo
  static const String catalogFlutter = '${assetDirectory}flutter.png';

  /// Drawer
  static const String catalogDrawer = '${assetDirectory}Drawer.png';

  /// RaisedButton
  static const String catalogButton = '${assetDirectory}button.png';

  /// FloatingActionButton
  static const String catalogFloatingActionButton =
      '${assetDirectory}FloatingActionButton.png';

  /// FlatButton
  static const String catalogFlatButton = '${assetDirectory}FlatButton.png';

  /// IconButton
  static const String catalogIconButton = '${assetDirectory}IconButton.png';

  /// PopupMenuButton
  static const String catalogPopupMenuButton =
      '${assetDirectory}PopupMenuButton.png';

  /// TextField
  static const String catalogTextField = '${assetDirectory}TextField.png';

  /// Checkbox
  static const String catalogCheckbox = '${assetDirectory}Checkbox.png';

  /// Radio
  static const String catalogRadio = '${assetDirectory}Radio.png';

  /// Switch
  static const String catalogSwitch = '${assetDirectory}Switch.png';

  /// Slider
  static const String catalogSlider = '${assetDirectory}Slider.png';

  /// TimePicker
  static const String catalogTimePicker = '${assetDirectory}TimePicker.png';

  /// SimpleDialog
  static const String catalogSimpleDialog = '${assetDirectory}SimpleDialog.png';

  /// AlertDialog
  static const String catalogAlertDialog = '${assetDirectory}AlertDialog.png';

  /// BottomSheet
  static const String catalogBottomSheet = '${assetDirectory}BottomSheet.png';

  /// ExpansionPanel
  static const String catalogExpansionPanel =
      '${assetDirectory}ExpansionPanel.png';

  /// SnackBar
  static const String catalogSnackBar = '${assetDirectory}SnackBar.png';

  /// Image
  static const String catalogImage = '${assetDirectory}image.png';

  /// Icon
  static const String catalogMdIcon = '${assetDirectory}md_icon.png';

  /// Chip
  static const String catalogChip = '${assetDirectory}Chip.png';

  /// Tooltip
  static const String catalogTooltip = '${assetDirectory}Tooltip.png';

  /// DataTable
  static const String catalogDataTable = '${assetDirectory}DataTable.png';

  /// Card
  static const String catalogCard = '${assetDirectory}Card.png';

  /// LinearProgressIndicator
  static const String catalogLinearProgressIndicator =
      '${assetDirectory}LinearProgressIndicator.png';

  /// ListTile
  static const String catalogListTile = '${assetDirectory}ListTile.png';

  /// Stepper
  static const String catalogStepper = '${assetDirectory}Stepper.png';

  /// Divider
  static const String catalogDivider = '${assetDirectory}Divider.png';

  /// Container
  static const String catalogContainer = '${assetDirectory}container.png';

  /// Row
  static const String catalogRow = '${assetDirectory}row.png';

  /// Column
  static const String catalogColumn = '${assetDirectory}column.png';

  /// Text
  static const String catalogText = '${assetDirectory}text.png';

  /// All bundled files, in declaration order.
  static const List<String> all = <String>[
    // Bottom navigation icons
    tabWeixinPressed,
    tabWeixinNormal,
    tabContactListPressed,
    tabContactListNormal,
    tabFindPressed,
    tabFindNormal,
    tabProfilePressed,
    tabProfileNormal,
    // App bar overflow menu
    menuGroup,
    menuAddFriend,
    menuScan,
    // Contacts header
    contactAddFriend,
    contactGroupChat,
    contactPublicAccount,
    // Discover rows
    discoverMoments,
    discoverScan,
    discoverShake,
    discoverTopStories,
    discoverSearch,
    discoverNearby,
    discoverBottle,
    discoverShopping,
    discoverGames,
    discoverMiniPrograms,
    // Profile rows
    meArrow,
    meWallet,
    meFavorites,
    meAlbum,
    meCards,
    meStickers,
    meSettings,
    // Widget catalogue images
    catalogScaffold,
    catalogAppbar,
    catalogBottomNavigationBar,
    catalogTabbar,
    catalogTabBarView,
    catalogMaterialApp,
    catalogFlutter,
    catalogDrawer,
    catalogButton,
    catalogFloatingActionButton,
    catalogFlatButton,
    catalogIconButton,
    catalogPopupMenuButton,
    catalogTextField,
    catalogCheckbox,
    catalogRadio,
    catalogSwitch,
    catalogSlider,
    catalogTimePicker,
    catalogSimpleDialog,
    catalogAlertDialog,
    catalogBottomSheet,
    catalogExpansionPanel,
    catalogSnackBar,
    catalogImage,
    catalogMdIcon,
    catalogChip,
    catalogTooltip,
    catalogDataTable,
    catalogCard,
    catalogLinearProgressIndicator,
    catalogListTile,
    catalogStepper,
    catalogDivider,
    catalogContainer,
    catalogRow,
    catalogColumn,
    catalogText,
  ];
}
