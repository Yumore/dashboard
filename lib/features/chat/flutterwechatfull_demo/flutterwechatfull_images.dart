/// Every bundled image copied from the source `assets/images/` tree.
///
/// The source keeps the same files in per-feature folders; the host bundles
/// them flat under [directory] (the only duplicate basenames in the source —
/// the two chat tab icons — are byte identical, so flattening is lossless).
/// SVG icons are rasterised once because the host does not depend on
/// `flutter_svg`; each constant below is pre-tinted with the colour the source
/// passed to `SvgPicture.asset(color: ...)`.
class FlutterWechatFullImages {
  const FlutterWechatFullImages._();

  /// Asset directory registered by the lead in `pubspec.yaml`.
  static const String directory = 'assets/flutterwechatfull_demo/';

  /// Launches the splash and login backgrounds.
  static const String launchImage = '${directory}LaunchImage.png';

  static const String introPage1 = '${directory}intro_page_1.png';
  static const String introPage2 = '${directory}intro_page_2.png';
  static const String introPage3 = '${directory}intro_page_3.png';
  static const String skipButton = '${directory}skip_btn.png';

  static const String adSkin1 = '${directory}121-bigskin-1.jpg';
  static const String adSkin2 = '${directory}121-bigskin-2.jpg';
  static const String adSkin3 = '${directory}121-bigskin-3.jpg';
  static const String adSkin4 = '${directory}121-bigskin-4.jpg';
  static const String adBackground = '${directory}SkyBg01_320x490.png';

  static const String closeIcon =
      '${directory}wsactionsheet_close_normal_16x16.png';
  static const String closeIconPressed =
      '${directory}wsactionsheet_close_press_16x16.png';
  static const String changeAvatar =
      '${directory}SignUpWC_ChangeAvatar_80x80.png';
  static const String changeAvatarPressed =
      '${directory}SignUpWC_ChangeAvatar_Hl_80x80.png';
  static const String passwordEye =
      '${directory}CellHidePassword_icon_22x14.png';
  static const String passwordEyePressed =
      '${directory}CellHidePassword_icon_HL_22x14.png';
  static const String agreementSelected =
      '${directory}wcpay_lqt_protocol_selected_16x16.png';
  static const String agreementUnselected =
      '${directory}wcpay_lqt_protocol_not_selected_16x16.png';

  static const String tabChats = '${directory}icons_outlined_chats.png';
  static const String tabChatsSelected =
      '${directory}icons_filled_chats_07c160.png';
  static const String tabContacts = '${directory}icons_outlined_contacts.png';
  static const String tabContactsSelected =
      '${directory}icons_filled_contacts_07c160.png';
  static const String tabDiscover = '${directory}icons_outlined_discover.png';
  static const String tabDiscoverSelected =
      '${directory}icons_filled_discover_07c160.png';
  static const String tabMe = '${directory}icons_outlined_me.png';
  static const String tabMeSelected = '${directory}icons_filled_me_07c160.png';

  static const String addAction = '${directory}icons_outlined_add2_181818.png';
  static const String contactsAdd =
      '${directory}icons_outlined_add-friends.png';
  static const String menuArrow = '${directory}menu_up_arrow.png';
  static const String menuChats = '${directory}icons_filled_chats_ffffff.png';
  static const String menuAddFriend =
      '${directory}icons_filled_add-friends_ffffff.png';
  static const String menuScan = '${directory}icons_filled_scan_ffffff.png';
  static const String menuPay = '${directory}icons_filled_pay_ffffff.png';
  static const String voiceInput =
      '${directory}icons_filled_voiceinput_white_666666.png';
  static const String mutedIcon =
      '${directory}AlbumMessageDisableNotifyIcon_15x15.png';

  static const String newFriends = '${directory}plugins_FriendNotify_36x36.png';
  static const String groupChat =
      '${directory}add_friend_icon_addgroup_36x36.png';
  static const String contactTag =
      '${directory}Contact_icon_ContactTag_36x36.png';
  static const String officialAccount =
      '${directory}add_friend_icon_offical_36x36.png';

  static const String defaultHead = '${directory}DefaultHead_48x48.png';
  static const String defaultProfileHead =
      '${directory}DefaultProfileHead_66x66.png';
  static const String arrow = '${directory}tableview_arrow_8x13.png';
  static const String qrCode = '${directory}setting_myQR_36x36.png';
  static const String labLogo = '${directory}WeChat_Lab_Logo_small_15x17.png';
  static const String selectedCheck = '${directory}icon_selected_20x20.png';

  static const String momentsCover = '${directory}kris_wu.png';
  static const String momentsTipArrow =
      '${directory}AlbumTimeLineTipArrow_15x15.png';
  static const String cameraFilled =
      '${directory}icons_filled_camera_ffffff.png';
  static const String cameraOutlined =
      '${directory}icons_outlined_camera_181818.png';

  static const String moments =
      '${directory}icons_outlined_colorful_moment.png';
  static const String scan = '${directory}icons_outlined_scan_3d83e6.png';
  static const String shake = '${directory}icons_outlined_shake_3d83e6.png';
  static const String look = '${directory}icons_outlined_news_f6c543.png';
  static const String search = '${directory}ff_IconSearch1_25x25.png';
  static const String nearby = '${directory}icons_outlined_nearby_3d83e6.png';
  static const String bottle = '${directory}icons_outlined_bottle_3d83e6.png';
  static const String shopping = '${directory}icons_outlined_shop_e75e58.png';
  static const String game = '${directory}icons_outlined_colorful_game.png';
  static const String miniProgram =
      '${directory}icons_outlined_miniprogram_6467e8.png';

  static const String pay = '${directory}icons_outlined_wechatpay.png';
  static const String favorites =
      '${directory}icons_outlined_colorful_favorites.png';
  static const String album = '${directory}icons_outlined_album_3d83e6.png';
  static const String cards = '${directory}icons_outlined_colorful_cards.png';
  static const String sticker = '${directory}icons_outlined_sticker_eda150.png';
  static const String setting = '${directory}icons_outlined_setting_3d83e6.png';

  static const String more = '${directory}icons_outlined_more_333333.png';
  static const String messageBlue =
      '${directory}icons_outlined_chats_576b95.png';
  static const String videoCallBlue =
      '${directory}icons_outlined_videocall_576b95.png';
  static const String videoCallFilled =
      '${directory}icons_filled_videocall_000000.png';
  static const String voiceCallFilled =
      '${directory}icons_filled_contacts_phone_000000.png';
  static const String male = '${directory}Contact_Male_18x18.png';
  static const String female = '${directory}Contact_Female_18x18.png';

  static const String addFriendSearch =
      '${directory}add_friend_searchicon_36x30.png';
  static const String addFriendQr = '${directory}add_friend_myQR_20x20.png';
  static const String radar = '${directory}add_friend_icon_reda_36x36.png';
  static const String faceGroup =
      '${directory}add_friend_icon_addgroup_36x36.png';
  static const String scanQr = '${directory}add_friend_icon_scanqr_36x36.png';
  static const String phoneContacts =
      '${directory}add_friend_icon_contacts_36x36.png';
  static const String weWork =
      '${directory}add_friend_icon_search_wework_36x36.png';

  static const String aboutIcon = '${directory}About_WeChat_AppIcon_64x64.png';
  static const String backgroundThumb =
      '${directory}ChatBackgroundThumb_00_100x100.png';

  /// The four bundled ad images, in source order.
  static const List<String> adSkins = <String>[
    adSkin1,
    adSkin2,
    adSkin3,
    adSkin4,
  ];

  /// Every bundled asset referenced by this module.
  static const List<String> all = <String>[
    launchImage,
    introPage1,
    introPage2,
    introPage3,
    skipButton,
    adSkin1,
    adSkin2,
    adSkin3,
    adSkin4,
    adBackground,
    closeIcon,
    closeIconPressed,
    changeAvatar,
    changeAvatarPressed,
    passwordEye,
    passwordEyePressed,
    agreementSelected,
    agreementUnselected,
    tabChats,
    tabChatsSelected,
    tabContacts,
    tabContactsSelected,
    tabDiscover,
    tabDiscoverSelected,
    tabMe,
    tabMeSelected,
    addAction,
    contactsAdd,
    menuArrow,
    menuChats,
    menuAddFriend,
    menuScan,
    menuPay,
    voiceInput,
    mutedIcon,
    newFriends,
    groupChat,
    contactTag,
    officialAccount,
    defaultHead,
    defaultProfileHead,
    arrow,
    qrCode,
    labLogo,
    selectedCheck,
    momentsCover,
    momentsTipArrow,
    cameraFilled,
    cameraOutlined,
    moments,
    scan,
    shake,
    look,
    search,
    nearby,
    bottle,
    shopping,
    game,
    miniProgram,
    pay,
    favorites,
    album,
    cards,
    sticker,
    setting,
    more,
    messageBlue,
    videoCallBlue,
    videoCallFilled,
    voiceCallFilled,
    male,
    female,
    addFriendSearch,
    addFriendQr,
    radar,
    faceGroup,
    scanQr,
    phoneContacts,
    weWork,
    aboutIcon,
    backgroundThumb,
    ...adSkins,
  ];
}
