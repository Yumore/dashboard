/// Endpoint constants of the public tsdm39 forum backend.
///
/// Ported 1:1 from the source project `tsdm_client`
/// (`lib/constants/url.dart` and the repositories that build urls inline).
/// The public site is `www.tsdm39.com`; the cookie session of a real account
/// is required by most endpoints but no credential is hard-coded here.
class TsdmApiUrls {
  const TsdmApiUrls._();

  /// Host in url.
  static const baseHost = 'www.tsdm39.com';

  /// Host in url, without www prefix.
  static const baseHostAlt = 'tsdm39.com';

  /// Server site base url.
  static const baseUrl = 'https://$baseHost';

  /// Homepage of tsdm.
  static const homePage = '$baseUrl/forum.php';

  /// Page to register a new account.
  static const signUpPage = '$baseUrl/member.php?mod=register.php';

  /// User profile page for the user with a given uid.
  static const uidProfilePage = '$baseUrl/home.php?mod=space&uid=';

  /// User profile page for the user with a given username.
  static const usernameProfilePage = '$baseUrl/home.php?mod=space&username=';

  /// Default fallback user avatar url when the user avatar is unavailable.
  static const noAvatarUrl = '$baseUrl/uc_server/images/noavatar_middle.gif';

  /// Notice page of the current logged user.
  static const noticeUrl = '$baseUrl/home.php?mod=space&do=notice';

  /// All read notice page of the current logged user.
  static const readNoticeUrl = '$baseUrl/home.php?mod=space&do=notice&isread=1';

  /// Private personal messages.
  static const personalMessageUrl =
      '$baseUrl/home.php?mod=space&do=pm&filter=privatepm';

  /// Broadcast messages.
  static const broadcastMessageUrl =
      '$baseUrl/home.php?mod=space&do=pm&filter=announcepm';

  /// Broadcast message detail page.
  static const broadcastMessageDetailUrl =
      '$baseUrl/home.php?mod=space&do=pm&subop=viewg&pmid=';

  /// Page containing all threads published by the current logged user.
  static const myThreadThreadUrl =
      '$baseUrl/home.php?mod=space&do=thread&view=me&type=thread';

  /// Page containing all posts published by the current logged user.
  static const myThreadReplyUrl =
      '$baseUrl/home.php?mod=space&do=thread&view=me&type=reply';

  /// Page containing credential information of the current user.
  static const modifyUserCredentialUrl =
      '$baseUrl/home.php?mod=spacecp&ac=profile&op=password';

  /// Use [modifyUserCredentialUrl] to check the user status.
  static const checkAuthenticationStateUrl = modifyUserCredentialUrl;

  /// Check authentication state, main page.
  static const checkAuthUrl = '$baseUrl/home.php?mod=spacecp';

  /// Check authentication state, mobile app json api used when switching user.
  static const checkAuthUrlV2 =
      '$baseUrl/home.php?mobile=yes&tsdmapp=1&mod=space&do=profile';

  /// Build the login url.
  static const loginBaseUrl =
      '$baseUrl/member.php?mobile=yes&tsdmapp=1&mod=logging&action=login&loginsubmit=yes';

  /// Build the logout url with a given [formHash].
  static String logoutUrl(String formHash) =>
      '$baseUrl/member.php?mod=logging&action=logout&formhash=$formHash';

  /// Fake form url used to fetch the login hash and the form hash.
  static const fakeFormUrl =
      '$baseUrl/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';

  /// Search plugin endpoint (`plugin.php`).
  static const searchUrl = '$baseUrl/plugin.php';

  /// Search plugin id used by the site search.
  static const searchPluginId = 'Kahrpba:search';

  /// Notification plugin id used by the mobile notification api.
  static const userNotifyPluginId = 'Kahrpba:usernotify';

  /// Mobile notification api url prefix, without the `last_updated` value.
  static const notificationV2UrlPrefix =
      '$baseUrl/plugin.php?mobile=yes&tsdmapp=1&id=$userNotifyPluginId&last_updated=';

  /// Chat page url used to send a message to the user with [uid].
  static String chatUrl(String uid, {int dateRange = 2}) =>
      '$baseUrl/home.php?mod=spacecp&ac=pm&op=showmsg&handlekey=showmsg_$uid&touid=$uid&pmid=0'
      '&daterange=$dateRange&infloat=yes&inajax=1&ajaxtarget=fwin_content_showMsgBox';

  /// Full chat history url of the user with [uid].
  static String chatFullHistoryUrl(String uid, {int? page}) =>
      '$baseUrl/home.php?mod=space&do=pm&subop=view&touid=$uid${page != null ? '&page=$page' : ''}#last';

  /// Recent chat history url of the user with [uid].
  static String chatRecentHistoryUrl(String uid, {int dateRange = 2}) =>
      '$baseUrl/home.php?mod=space&do=pm&op=showmsg&msgonly=1&touid=$uid&pmid=0&inajax=1&daterange=$dateRange';

  /// Url of the `fwin_content_reply` post reply window.
  static const replyPostWindowSuffix =
      '&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply';

  /// Build the thread page url.
  ///
  /// [orderType] is `&ordertype=$i` or empty, [visibleUid] is
  /// `&authorid=$uid` or empty.
  static String threadUrl({
    required String tid,
    int pageNumber = 1,
    String orderType = '',
    String visibleUid = '',
  }) =>
      '$baseUrl/forum.php?mod=viewthread&tid=$tid&extra=page%3D1$orderType$visibleUid&page=$pageNumber';

  /// Url that redirects to the page containing the post [pid].
  static String redirectToPostUrl(String pid) =>
      '$baseUrl/forum.php?mod=redirect&goto=findpost&pid=$pid';

  /// Build the operation log url of thread [tid].
  static String operationLogUrl(String tid) =>
      '$baseUrl/forum.php?mod=misc&action=viewthreadmod&tid=$tid'
      '&infloat=yes&handlekey=viewthreadmod&inajax=1&ajaxtarget=fwin_content_viewthreadmod';

  /// Mobile thread json api url.
  static String threadJsonUrl({required String tid, required int page}) =>
      '$baseUrl/forum.php?mobile=yes&tsdmapp=1&mod=viewthread&tid=$tid&page=$page';

  /// Target url to post a reply to thread [tid] in forum [fid].
  static String replyThreadUrl(String fid, String tid) =>
      '$homePage?mod=post&action=reply&fid=$fid&tid=$tid&extra=&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1';

  /// Target url to post a reply to another post in thread [tid], forum [fid].
  static String replyPostUrl(String fid, String tid) =>
      '$homePage?mod=post&infloat=yes&action=reply&fid=$fid&extra=&tid=$tid&replysubmit=yes&inajax=1';

  /// Target url to get the dialog shown before purchasing a thread.
  static String purchaseDialogUrl(String tid, String pid) =>
      '$homePage?mod=misc&action=pay&tid=$tid&pid=$pid&infloat=yes&handlekey=pay&inajax=1&ajaxtarget=fwin_content_pay';

  /// Target url to send a message to user [touid].
  static String sendMessageUrl(String touid) =>
      '$baseUrl/home.php?mod=spacecp&ac=pm&op=send&touid=$touid&inajax=1';

  /// Url of images having a rendering issue with Impeller.
  static const tmpImpellerWorkaroundUrls = [
    'https://$baseHost/static/image/common/back.gif',
    'https://$baseHostAlt/static/image/common/back.gif',
  ];
}
