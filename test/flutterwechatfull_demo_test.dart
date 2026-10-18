import 'dart:async';
import 'dart:io';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_about_us_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_account_security_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_add_friend_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_add_way_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_binding_mailbox_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_chat_background_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_chat_record_backup_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_check_scope_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_contact_more_info_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_contact_setting_info_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_contact.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_discover_manager_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_friend_permission_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_general_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_message_notify_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_more_info_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_more_security_setting_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_photo_browser_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_privates_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_profile_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_resource_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_search_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_setting_gender_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_setting_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_signature_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_user_info_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_conversation.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_demo_data.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_demo_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_home_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_images.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_local_image.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_login_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_other_login_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_phone_login_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_register_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_contact_info_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_contacts_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_zone_code_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves the module's bundled files straight from the repository so the tests
/// still see real pixels while `pubspec.yaml` (owned by the lead) has not
/// registered `assets/flutterwechatfull_demo/` yet.
class _DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final Uint8List bytes = await File(key).readAsBytes();
    return ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    if (key == 'AssetManifest.bin') {
      final Map<String, Object?> manifest = <String, Object?>{};
      for (final String asset in FlutterWechatFullImages.all) {
        manifest[asset] = <Object?>[
          <String, Object?>{'asset': asset},
        ];
      }
      final ByteData data = const StandardMessageCodec().encodeMessage(
        manifest,
      )!;
      return parser(data);
    }
    return super.loadStructuredBinaryData<T>(key, parser);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final File file = File(key);
    if (await file.exists()) {
      return file.readAsString();
    }
    return '[]';
  }
}

/// Answers every avatar request with a valid image so the tests stay offline.
class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

class _OfflineHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _OfflineRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _OfflineRequest(url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OfflineRequest implements HttpClientRequest {
  _OfflineRequest(this.uri);

  @override
  final Uri uri;

  @override
  final HttpHeaders headers = _OfflineHeaders();

  @override
  int contentLength = 0;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  bool bufferOutput = true;

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async => _OfflineResponse();

  @override
  Future<HttpClientResponse> get done async => _OfflineResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OfflineHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _OfflineResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  String get reasonPhrase => 'OK';

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _OfflineHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A 1x1 transparent PNG used for every simulated network avatar.
final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Future<void> pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    DefaultAssetBundle(
      bundle: _DiskAssetBundle(),
      child: MaterialApp(home: page),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Finder localImage(String path) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is FlutterWechatFullLocalImage && widget.path == path,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _OfflineHttpOverrides();
  });

  group('bundled sample data', () {
    test('20 conversations in source order', () {
      final List<FlutterWechatFullConversation> conversations =
          FlutterWechatFullDemoData.conversations;
      expect(conversations.length, 20);
      expect(conversations.first.name, '腾讯新闻');
      expect(conversations.first.text, '工作996，生病ICU？关注：年轻人该如何奋斗');
      expect(conversations.first.type, '2');
      expect(conversations.first.unreadCount, 2);
      expect(conversations[1].name, '芈月');
      expect(conversations[1].text, '整容手术都是骗人的，青春美貌全靠把你吸干');
      expect(conversations[2].name, '微信运动');
      expect(conversations[2].type, '0');
      expect(conversations.last.name, '小姐姐✨');
      expect(conversations.last.avatars.length, 9);
      expect(
        conversations.map((FlutterWechatFullConversation c) => c.name).toList(),
        <String>[
          '腾讯新闻',
          '芈月',
          '微信运动',
          '貂蝉',
          'QQ邮箱提醒',
          '不知火舞',
          '花木兰',
          '微信游戏',
          '武则天',
          '雅典娜',
          '元歌',
          'QQ安全中心',
          '草丛三婊',
          '订阅号消息',
          '回血四人帮',
          '五虎上将',
          '六亲不认',
          '刺客信条',
          '仙侠豪情',
          '小姐姐✨',
        ],
      );
    });

    test('100 contacts with their mock ids and pictures', () {
      final List<FlutterWechatFullContact> contacts =
          FlutterWechatFullDemoData.contacts;
      expect(contacts.length, 100);
      expect(contacts.first.name, '马超');
      expect(contacts.first.id, '10000000');
      expect(contacts.first.wechatId, 'machao');
      expect(contacts.first.tag, 'M');
      expect(contacts.first.remarks, '冷晖之枪');
      expect(contacts.first.featureSign, '我的枪去而复返，你的生命有去无回');
      expect(contacts.first.pictures.isEmpty, isFalse);
      expect(contacts.last.name, '镜');
      expect(contacts.last.id, '10000099');
      expect(
        contacts.map((FlutterWechatFullContact c) => c.name).toSet().length,
        100,
      );
    });

    test('193 zone codes and 20 languages', () {
      expect(FlutterWechatFullDemoData.zoneCodes.length, 193);
      expect(FlutterWechatFullDemoData.zoneCodes.first.name, '安道尔共和国');
      expect(FlutterWechatFullDemoData.zoneCodes.first.englishName, 'Andorra');
      expect(FlutterWechatFullDemoData.zoneCodes.first.tel, '376');
      expect(FlutterWechatFullDemoData.zoneCodes.first.tag, 'A');
      expect(
        FlutterWechatFullDemoData.zoneCodes
            .where((zone) => zone.name == '中国大陆')
            .first
            .tel,
        '86',
      );
      expect(FlutterWechatFullDemoData.languages.length, 20);
      expect(FlutterWechatFullDemoData.languages.first, '简体中文');
      expect(FlutterWechatFullDemoData.languages[3], 'English');
      expect(FlutterWechatFullDemoData.languages.last, 'Français');
      expect(FlutterWechatFullDemoData.languages.contains('한국어'), isFalse);
      expect(FlutterWechatFullDemoData.searchCategories.length, 6);
      expect(FlutterWechatFullDemoData.searchCategories.first, '朋友圈');
      expect(FlutterWechatFullDemoData.searchCategories.last, '表情');
    });
  });

  group('splash ad → login', () {
    testWidgets('counts down from 跳过 5 and lands on 登录', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullDemoPage());
      expect(find.text('跳过 5'), findsOneWidget);
      expect(localImage(FlutterWechatFullImages.adSkins.first), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('跳过 4'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await settle(tester);
      expect(find.text('登陆'), findsOneWidget);
      expect(find.text('注册'), findsOneWidget);
      expect(find.text('简体中文'), findsOneWidget);
    });
  });

  group('login forms', () {
    testWidgets('login page opens the other-login form and the register form',
        (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullLoginPage());
      expect(find.text('登陆'), findsOneWidget);
      expect(find.text('注册'), findsOneWidget);

      await tester.tap(find.text('登陆'));
      await settle(tester);
      expect(find.text('手机号登录'), findsOneWidget);
      expect(find.text('国家/地区'), findsOneWidget);
      expect(find.text('中国大陆'), findsOneWidget);
      expect(find.text('下一步'), findsOneWidget);

      await tester.tap(localImage(FlutterWechatFullImages.closeIcon));
      await tester.pumpAndSettle();
      await tester.tap(find.text('注册'));
      await settle(tester);
      expect(find.text('用手机号注册'), findsOneWidget);
      expect(find.text('昵称'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
    });

    testWidgets('other login switches ways and picks a zone code',
        (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullOtherLoginPage());
      expect(find.text('下一步'), findsOneWidget);

      await tester.tap(find.text('中国大陆'));
      await settle(tester);
      expect(find.text('选择国家和地区'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(FlutterWechatFullZoneCodePickerPage),
          matching: find.byType(TextField),
        ),
        '中国',
      );
      await tester.pump();
      final Finder pickerRow = find.descendant(
        of: find.byType(FlutterWechatFullZoneCodePickerPage),
        matching: find.text('中国大陆'),
      );
      expect(pickerRow, findsOneWidget);
      await tester.tap(pickerRow);
      await tester.pumpAndSettle();
      expect(find.text('中国大陆'), findsOneWidget);

      await tester.tap(find.text('用微信号/QQ号/邮箱登录'));
      await tester.pump();
      expect(find.text('账号'), findsOneWidget);
      expect(find.text('微信号/QQ号/邮箱'), findsOneWidget);
      expect(find.text('登录'), findsOneWidget);
    });

    testWidgets('register validates phone and password with the source dialogs',
        (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullRegisterPage());
      expect(find.text('注册'), findsWidgets);

      await tester.enterText(
        find.byType(TextField).at(0),
        '陈晨',
      );
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.enterText(find.byType(TextField).at(2), 'password1');
      await tester.pump();

      await tester.ensureVisible(find.text('我已阅读并同意'));
      await tester.tap(localImage(FlutterWechatFullImages.agreementUnselected));
      await tester.pump();

      await tester.ensureVisible(find.text('注册').last);
      final Finder registerButton = find.ancestor(
        of: find.text('注册'),
        matching: find.byType(InkWell),
      );
      await tester.ensureVisible(registerButton.last);
      await tester.tap(registerButton.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('手机号码错误'), findsOneWidget);
      await tester.tap(find.text('确定'));
      await settle(tester);

      await tester.enterText(find.byType(TextField).at(1), '13874385438');
      await tester.enterText(find.byType(TextField).at(2), '12345678');
      await tester.pump();
      await tester.ensureVisible(registerButton.last);
      await tester.tap(registerButton.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('密码必须是8-16位英文字母、数字、字符组合（不能是纯数字）'),
        findsOneWidget,
      );
    });
  });

  group('home tabs', () {
    testWidgets('lists the sample conversations in order', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      expect(find.text('腾讯新闻'), findsOneWidget);
      expect(find.text('芈月'), findsOneWidget);
      expect(find.text('微信运动'), findsOneWidget);
      expect(find.text('2019/12/01'), findsWidgets);
      expect(
        tester.getTopLeft(find.text('腾讯新闻')).dy <
            tester.getTopLeft(find.text('芈月')).dy,
        isTrue,
      );
    });

    testWidgets('switches to 通讯录, 发现 and 我', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());

      await tester.tap(find.text('通讯录'));
      await tester.pump();
      expect(find.text('新的朋友'), findsOneWidget);
      expect(find.text('群聊'), findsOneWidget);
      expect(find.text('标签'), findsOneWidget);
      expect(find.text('公众号'), findsOneWidget);
      expect(find.text('安琪拉'), findsOneWidget);

      final Finder contactsList = find
          .descendant(
            of: find.byType(FlutterWechatFullContactsPage),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('100位联系人'),
        600.0,
        scrollable: contactsList,
        maxScrolls: 40,
      );
      expect(find.text('100位联系人'), findsOneWidget);

      await tester.tap(find.text('发现').last);
      await settle(tester);
      expect(find.text('朋友圈'), findsOneWidget);
      expect(find.text('扫一扫'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);

      await tester.tap(find.text('我'));
      await tester.pump();
      expect(find.text('Mike-乱港三千-Mr_元先森'), findsOneWidget);
      expect(find.text('微信号：codermikehe'), findsOneWidget);
      expect(find.text('支付'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });
  });

  group('navigation and dead controls', () {
    testWidgets('conversation rows and the 微信 menu are inert', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('腾讯新闻'));
      await tester.pump();
      expect(find.text('腾讯新闻'), findsOneWidget);
      expect(find.text('微信'), findsWidgets);

      await tester.tap(localImage(FlutterWechatFullImages.addAction));
      await tester.pump();
      expect(find.text('发起群聊'), findsOneWidget);
      expect(find.text('添加朋友'), findsOneWidget);
      expect(find.text('扫一扫'), findsOneWidget);
      expect(find.text('收付款'), findsOneWidget);

      await tester.tap(find.text('发起群聊'));
      await tester.pump();
      expect(find.text('发起群聊'), findsNothing);
    });

    testWidgets('swipe actions stay inert', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.drag(find.text('腾讯新闻'), const Offset(-200.0, 0.0));
      await tester.pump();
      expect(find.text('不再关注'), findsOneWidget);
      expect(find.text('删除'), findsWidgets);

      await tester.tap(find.text('删除').first);
      await tester.pump();
      expect(find.text('腾讯新闻'), findsOneWidget);
    });

    testWidgets('discover only opens 朋友圈', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('发现'));
      await tester.pump();
      await tester.tap(find.text('扫一扫'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('发现'), findsWidgets);
      expect(find.text('扫一扫'), findsOneWidget);

      await tester.tap(find.text('朋友圈'));
      await settle(tester);
      expect(find.text('10条新消息'), findsOneWidget);
    });

    testWidgets('search overlay shows the dead categories', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('搜索'));
      await settle(tester);
      expect(find.text('搜索指定内容'), findsOneWidget);
      expect(find.text('朋友圈'), findsOneWidget);
      expect(find.text('文章'), findsOneWidget);
      expect(find.text('公众号'), findsOneWidget);
      expect(find.text('小程序'), findsOneWidget);
      expect(find.text('音乐'), findsOneWidget);
      expect(find.text('表情'), findsOneWidget);
      expect(find.text('按住 说话'), findsOneWidget);
    });

    testWidgets('contact detail, friend permission and inert 发消息',
        (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('通讯录'));
      await tester.pump();
      await tester.tap(find.text('安琪拉'));
      await settle(tester);

      expect(find.text('微信号：anqila'), findsOneWidget);
      expect(find.text('备注和标签'), findsOneWidget);
      expect(find.text('朋友权限'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('更多信息'),
        300.0,
        scrollable: find.descendant(
          of: find.byType(FlutterWechatFullContactInfoPage),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pump();
      expect(find.text('更多信息'), findsOneWidget);
      expect(find.text('发消息'), findsOneWidget);

      await tester.tap(find.text('发消息'));
      await tester.pump();
      expect(find.byType(FlutterWechatFullContactInfoPage), findsOneWidget);

      await tester.drag(
        find.descendant(
          of: find.byType(FlutterWechatFullContactInfoPage),
          matching: find.byType(Scrollable),
        ),
        const Offset(0.0, 800.0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('朋友权限'));
      await settle(tester);
      expect(find.text('设置朋友权限'), findsOneWidget);
      expect(find.text('聊天、朋友圈、微信运动等'), findsOneWidget);
      expect(find.text('仅聊天'), findsOneWidget);
    });

    testWidgets('settings chain reaches 邮箱地址', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('我'));
      await tester.pump();
      await tester.tap(find.text('设置'));
      await settle(tester);

      expect(find.text('账号与安全'), findsOneWidget);
      expect(find.text('新消息通知'), findsOneWidget);
      expect(find.text('隐私'), findsOneWidget);
      expect(find.text('通用'), findsOneWidget);
      expect(find.text('关于微信'), findsOneWidget);
      await tester.tap(find.text('账号与安全'));
      await settle(tester);
      expect(find.text('微信号'), findsOneWidget);
      expect(find.text('手机号'), findsOneWidget);
      expect(find.text('未绑定'), findsOneWidget);

      await tester.tap(find.text('更多安全设置'));
      await settle(tester);
      expect(find.text('QQ号'), findsOneWidget);
      expect(find.text('邮箱地址'), findsOneWidget);

      await tester.tap(find.text('邮箱地址'));
      await settle(tester);
      expect(find.text('请输入邮箱地址'), findsOneWidget);
      expect(find.text('你可以用验证过的邮箱来找回微信密码'), findsOneWidget);

    });

    testWidgets('language picker updates 通用', (WidgetTester tester) async {
      await pumpPage(tester, const FlutterWechatFullHomePage());
      await tester.tap(find.text('我'));
      await tester.pump();
      await tester.tap(find.text('设置'));
      await settle(tester);
      await tester.tap(find.text('通用'));
      await settle(tester);
      expect(find.text('多语言'), findsOneWidget);
      expect(find.text('简体中文'), findsOneWidget);

      await tester.tap(find.text('多语言'));
      await settle(tester);
      expect(find.text('设置语言'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsWidgets);
      expect(find.text('简体中文'), findsNothing);
    });

    testWidgets('phone login validates the password', (WidgetTester tester) async {
      await pumpPage(
        tester,
        const FlutterWechatFullPhoneLoginPage(
          phone: '13874385438',
          zoneCode: '86',
        ),
      );
      expect(find.text('+86 138 7438 5438'), findsOneWidget);
      expect(find.text('用短信验证码登录'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '123');
      await tester.pump();
      await tester.ensureVisible(find.text('登录'));
      await tester.tap(find.text('登录'));
      await tester.pump();
      expect(find.text('账号或密码错误，请重新填写'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await settle(tester);
      await tester.tap(find.text('用短信验证码登录'));
      await tester.pump();
      expect(find.text('验证码'), findsOneWidget);
      expect(find.text('请输入验证码'), findsOneWidget);
      expect(find.text('获取验证码'), findsOneWidget);
    });
  });

  group('screen smoke', () {
    final FlutterWechatFullContact contact = FlutterWechatFullDemoData.contacts
        .firstWhere((FlutterWechatFullContact c) => c.name == '安琪拉');
    final List<Widget> screens = <Widget>[
      const FlutterWechatFullAboutUsPage(),
      const FlutterWechatFullAccountSecurityPage(),
      const FlutterWechatFullAddFriendPage(),
      const FlutterWechatFullAddWayPage(),
      const FlutterWechatFullBindingMailboxPage(),
      const FlutterWechatFullChatBackgroundPage(),
      const FlutterWechatFullChatRecordBackupPage(),
      const FlutterWechatFullCheckScopePage(value: 'all'),
      FlutterWechatFullContactMoreInfoPage(contact: contact),
      FlutterWechatFullContactSettingInfoPage(contact: contact),
      const FlutterWechatFullDiscoverManagerPage(),
      FlutterWechatFullFriendPermissionPage(contact: contact),
      const FlutterWechatFullGeneralPage(),
      const FlutterWechatFullMessageNotifyPage(),
      const FlutterWechatFullMoreInfoPage(),
      const FlutterWechatFullMoreSecuritySettingPage(),
      const FlutterWechatFullPhotoBrowserPage(
        photos: <String>['https://example.com/a.jpg'],
      ),
      const FlutterWechatFullPrivatesPage(),
      const FlutterWechatFullProfilePage(),
      const FlutterWechatFullResourcePage(),
      const FlutterWechatFullSearchPage(),
      const FlutterWechatFullSettingGenderPage(value: '男'),
      const FlutterWechatFullSettingPage(),
      const FlutterWechatFullSignaturePage(text: '生死看淡，不服就干'),
      const FlutterWechatFullUserInfoPage(),
    ];

    for (final Widget screen in screens) {
      testWidgets('${screen.runtimeType} renders', (WidgetTester tester) async {
        await pumpPage(tester, screen);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
