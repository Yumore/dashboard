import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_conversation.dart';
import 'flutterwechatfull_picture.dart';
import 'flutterwechatfull_zone_code.dart';

/// Sample data ported verbatim from the flutterWeChat demo's bundled mock JSON.
///
/// Source: `mock/mainframe.json` (conversations), `mock/contacts.json`
/// (contacts), `mock/world_zone_code.json` (country codes) and
/// `mock/user.json` (profile header). Nothing is generated at runtime.
class FlutterWechatFullDemoData {
  const FlutterWechatFullDemoData._();

  /// Bundled assets copied from the source `assets/images/` tree.
  static const String assetDirectory = 'assets/flutterwechatfull_demo/';

  /// App version shown in 设置 → 关于微信.
  static const String appVersion = '微信7.0.3';

  /// About page version line.
  static const String aboutVersion = 'Version 7.0.8';

  /// Language entries from the source language picker, in order.
  static const List<String> languages = <String>[
    '简体中文',
    '繁體中文（台灣）',
    '繁體中文（香港）',
    'English',
    'Bahasa Indonesia',
    'Bahasa Melayu',
    'español',
    'Italiano',
    '日本語',
    'Polski',
    'Português',
    'Русский',
    'ภาษาไทย',
    'Tiếng Việt',
    'العربية',
    'हिन्दी',
    'עברית',
    'Türkçe',
    'Deutsch',
    'Français',
  ];

  /// Search categories shown over the expanded search field.
  static const List<String> searchCategories = <String>[
    '朋友圈',
    '文章',
    '公众号',
    '小程序',
    '音乐',
    '表情',
  ];

  /// Conversation list, in source order (`mock/mainframe.json`).
  static const List<FlutterWechatFullConversation> conversations =
      <FlutterWechatFullConversation>[
        FlutterWechatFullConversation(
          id: '10000',
          name: '腾讯新闻',
          avatars: <String>['assets/flutterwechatfull_demo/tencent_news.png'],
          text: '工作996，生病ICU？关注：年轻人该如何奋斗',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '2',
          unreadCount: 2,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10001',
          name: '芈月',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121.jpg',
          ],
          text: '整容手术都是骗人的，青春美貌全靠把你吸干',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10002',
          name: '微信运动',
          avatars: <String>['assets/flutterwechatfull_demo/wechat_motion.png'],
          text: '[应用消息]',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '0',
          unreadCount: 4,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10003',
          name: '貂蝉',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141.jpg',
          ],
          text: '想欣赏妾身的舞姿吗？',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10004',
          name: 'QQ邮箱提醒',
          avatars: <String>[
            'assets/flutterwechatfull_demo/Plugins_QQMail_29x29.png',
          ],
          text: '拉勾网：社群招新|加入拉钩前端干货群，每天成长5分钟，助你跑赢同龄人',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 1,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10005',
          name: '不知火舞',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/157/157.jpg',
          ],
          text: 'りゅうえんぶ',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10006',
          name: '花木兰',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154.jpg',
          ],
          text: '[动画表情]',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10007',
          name: '微信游戏',
          avatars: <String>['assets/flutterwechatfull_demo/wechat_game.png'],
          text: '【订阅号消息】我的王者荣耀战报',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '2',
          unreadCount: 9,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10008',
          name: '武则天',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136.jpg',
          ],
          text: '普天之下莫非王土 做女人难做女帝更难....',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10009',
          name: '雅典娜',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183.jpg',
          ],
          text: '正视你的邪恶！',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 7,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10010',
          name: '元歌',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/125/125.jpg',
          ],
          text: '用头脑，而不是武力。',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10011',
          name: 'QQ安全中心',
          avatars: <String>['assets/flutterwechatfull_demo/qq_safeguard.png'],
          text: '请接招：这里有份QQ防封秘籍！',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '2',
          unreadCount: 6,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10012',
          name: '草丛三婊',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152.jpg',
          ],
          text: '王昭君：凛冬已至，故乡的梅花开了吗？',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10013',
          name: '订阅号消息',
          avatars: <String>[
            'assets/flutterwechatfull_demo/subscription_number.png',
          ],
          text: '脚踝终结者：德鲁大叔 凯里.欧文',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '0',
          unreadCount: 1,
          badgeVisible: true,
          badgeDot: true,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10014',
          name: '回血四人帮',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/176/176.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501.jpg',
          ],
          text: '蔡文姬：左三圈~右三圈~扭一扭转一转~人家也作萝莉控~',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: true,
        ),
        FlutterWechatFullConversation(
          id: '10015',
          name: '五虎上将',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/192/192.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/518/518.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/171/171.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140.jpg',
          ],
          text: '关羽：聪明，就该跟我的大刀保持安全距离',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 136,
          badgeVisible: true,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10016',
          name: '六亲不认',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108.jpg',
          ],
          text: '程咬金：一个字,干！',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10017',
          name: '刺客信条',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/162/162.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/137/137.jpg',
          ],
          text: '李白：可以赶尽，无法杀绝。',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10018',
          name: '仙侠豪情',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/529/529.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/511/511.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/178/178.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/187/187.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180.jpg',
          ],
          text: '孙悟空：超出三界之外，不在五行之中',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
        FlutterWechatFullConversation(
          id: '10019',
          name: '小姐姐✨',
          avatars: <String>[
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/523/523.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/515/515.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127.jpg',
            'https://game.gtimg.cn/images/yxzj/img201606/heroimg/513/513.jpg',
          ],
          text: '孙尚香：大小姐驾到，通通闪开！',
          createdAt: 'Tue Apr 09 00:05:03 +0800 2019',
          type: '1',
          unreadCount: 0,
          badgeVisible: false,
          badgeDot: false,
          messageFree: false,
        ),
      ];

  /// Contact list, in source order (`mock/contacts.json`).
  static const List<FlutterWechatFullContact>
  contacts = <FlutterWechatFullContact>[
    FlutterWechatFullContact(
      id: '10000000',
      name: '马超',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/518/518.jpg',
      wechatId: 'machao',
      featureSign: '我的枪去而复返，你的生命有去无回',
      remarks: '冷晖之枪',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '幸存者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/518/518-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/518/518-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冷晖之枪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/518/518-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/518/518-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000001',
      name: '曜',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/522/522.jpg',
      wechatId: 'yao',
      featureSign: '我没耍帅，有些东西是天生的。',
      remarks: '星辰之子',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '归虚梦演',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/522/522-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/522/522-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '星辰之子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/522/522-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/522/522-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000002',
      name: '云中君',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/506/506.jpg',
      wechatId: 'yunzhongjun',
      featureSign: '记忆触手可得，蓝天延绵不绝',
      remarks: '苍云之翼',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '荷鲁斯之眼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/506/506-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/506/506-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '苍云之翼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/506/506-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/506/506-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000003',
      name: '盘古',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/529/529.jpg',
      wechatId: 'pangu',
      featureSign: '与其享乐，还是冲锋适合我',
      remarks: '破晓之神',
      gender: 0,
      tag: 'P',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '创世神祝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/529/529-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/529/529-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '破晓之神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/529/529-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/529/529-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000004',
      name: '李信',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/507/507.jpg',
      wechatId: 'lixin',
      featureSign: '侯非侯，王非王，千乘万骑走北芒',
      remarks: '谋世之战',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '灼热之刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/507/507-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/507/507-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '谋世之战',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/507/507-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/507/507-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000005',
      name: '孙策',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/510/510.jpg',
      wechatId: 'sunce',
      featureSign: '梦想着梦想中国家的梦想',
      remarks: '光明之海',
      gender: 0,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '猫狗日记',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/510/510-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/510/510-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '海之征途',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/510/510-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/510/510-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '光明之海',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/510/510-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/510/510-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000006',
      name: '狂铁',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/503/503.jpg',
      wechatId: 'kuangtie',
      featureSign: '放弃就等同失败',
      remarks: '战车意志',
      gender: 0,
      tag: 'K',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '御狮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/503/503-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/503/503-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '命运角斗场',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/503/503-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/503/503-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '战车意志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/503/503-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/503/503-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000007',
      name: '苏烈',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/194/194.jpg',
      wechatId: 'sulie',
      featureSign: '长城在，故乡就在',
      remarks: '不屈铁壁',
      gender: 0,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '玄武志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/194/194-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/194/194-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '坚韧之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/194/194-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/194/194-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '爱与和平',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/194/194-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/194/194-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '不屈铁壁',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/194/194-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/194/194-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000008',
      name: '凯',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/193/193.jpg',
      wechatId: 'kai',
      featureSign: '以绝望为剑,铸逝者为铠!',
      remarks: '破灭刃锋',
      gender: 0,
      tag: 'K',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '青龙志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/193/193-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/193/193-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '曙光守护者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/193/193-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/193/193-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '龙域领主',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/193/193-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/193/193-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '破灭刃锋',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/193/193-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/193/193-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000009',
      name: '哪吒',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180.jpg',
      wechatId: 'nezha',
      featureSign: '你的空手接不住我的白刃',
      remarks: '桀骜炎枪',
      gender: 0,
      tag: 'N',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '次元突破',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/180/180-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逐梦之翼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/180/180-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '三太子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/180/180-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '桀骜炎枪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/180/180-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/180/180-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000010',
      name: '杨戬',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/178/178.jpg',
      wechatId: 'yangjian',
      featureSign: '刀锋所划之地 便是疆土',
      remarks: '根源之目',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '永曜之星',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/178/178-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/178/178-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '埃及法老',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/178/178-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/178/178-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '根源之目',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/178/178-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/178/178-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000011',
      name: '橘右京',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/163/163.jpg',
      wechatId: 'juyoujing',
      featureSign: 'ジタザシジズシギグゲグスシ',
      remarks: '神梦一刀',
      gender: 1,
      tag: 'J',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '战争女神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/163/163-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/163/163-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '神梦一刀',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/163/163-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/163/163-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000012',
      name: '雅典娜',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183.jpg',
      wechatId: 'yadianna',
      featureSign: '正视你的邪恶！',
      remarks: '圣域余晖',
      gender: 1,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '神奇女侠',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/183/183-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冰冠公主',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/183/183-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '战争女神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/183/183-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣域余晖',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/183/183-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/183/183-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000013',
      name: '夏侯惇',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126.jpg',
      wechatId: 'xiahoudun',
      featureSign: '没错，我就是呼唤胜利的男神',
      remarks: '不羁之风',
      gender: 0,
      tag: 'X',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '朔风刀',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/126/126-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '无限飓风号',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/126/126-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '乘风破浪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/126/126-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '战争骑士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/126/126-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '不羁之风',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/126/126-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/126/126-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000014',
      name: '关羽',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140.jpg',
      wechatId: 'guanyu',
      featureSign: '聪明，就该跟我的大刀保持安全距离',
      remarks: '一骑当千',
      gender: 0,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '冰锋战神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/140/140-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天启骑士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/140/140-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '龙腾万里',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/140/140-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '一骑当千',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/140/140-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/140/140-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000015',
      name: '钟馗',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/175/175.jpg',
      wechatId: 'zhongkui',
      featureSign: '垃圾就该呆在垃圾桶里',
      remarks: '虚灵城判',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '神迹守卫',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/175/175-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/175/175-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '地府判官',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/175/175-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/175/175-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '虚灵城判',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/175/175-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/175/175-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000016',
      name: '刘备',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/170/170.jpg',
      wechatId: 'liubei',
      featureSign: '除暴安良是责任，行善积德是兴趣',
      remarks: '仁德义枪',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '汉昭烈帝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/170/170-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/170/170-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '纽约教父',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/170/170-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/170/170-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '万事如意',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/170/170-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/170/170-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '仁德义枪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/170/170-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/170/170-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000017',
      name: '花木兰',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154.jpg',
      wechatId: 'huamulan',
      featureSign: '姐来展示下高端操作',
      remarks: '传说之刃',
      gender: 1,
      tag: 'H',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '瑞麟志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冠军飞将',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '青春决赛季',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '水晶猎龙者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '兔女郎',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '剑舞者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '传说之刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/154/154-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/154/154-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000018',
      name: '吕布',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123.jpg',
      wechatId: 'lvbu',
      featureSign: '无法得到那就将他彻底毁掉',
      remarks: '无双之魔',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '野性能量',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '猎兽之王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '末日机甲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天魔缭乱',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣诞狂欢',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '无双之魔',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/123/123-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/123/123-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000019',
      name: '宫本武藏',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130.jpg',
      wechatId: 'gongbenwuzang',
      featureSign: '天下无双',
      remarks: '剑圣',
      gender: 0,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '霸王丸',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '地狱之眼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '万象初新',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '未来纪元',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鬼剑武藏',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '剑圣',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/130/130-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/130/130-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000020',
      name: '露娜',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146.jpg',
      wechatId: 'luna',
      featureSign: '今天是对面的坏日子',
      remarks: '月光之女',
      gender: 1,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '一生所爱',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/146/146-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '紫霞仙子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/146/146-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '绯红之刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/146/146-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '哥特玫瑰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/146/146-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '月光之女',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/146/146-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/146/146-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000021',
      name: '韩信',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150.jpg',
      wechatId: 'hanxin',
      featureSign: '必将百倍奉还',
      remarks: '国士无双',
      gender: 0,
      tag: 'H',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '飞衡',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逐梦之影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '白龙吟',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '教廷特使',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '街头霸王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '国士无双',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/150/150-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/150/150-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000022',
      name: '孙悟空',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167.jpg',
      wechatId: 'sunwukong',
      featureSign: '超出三界之外，不在五行之中',
      remarks: '齐天大圣',
      gender: 0,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '大圣娶亲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '全息碎影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '至尊宝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '美猴王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '西部大镖客',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '地狱火',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '齐天大圣',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/167/167-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/167/167-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000023',
      name: '曹操',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128.jpg',
      wechatId: 'caocao',
      featureSign: '宁教我负天下人',
      remarks: '鲜血枭雄',
      gender: 0,
      tag: 'C',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '天狼征服者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '烛龙',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '死神来了',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '幽灵船长',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '超能战警',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鲜血枭雄',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/128/128-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/128/128-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000024',
      name: '亚瑟',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166.jpg',
      wechatId: 'yase',
      featureSign: '王者背负，王者审判，王者不可阻挡',
      remarks: '圣骑之力',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '心灵战警',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/166/166-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '狮心王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/166/166-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '死亡骑士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/166/166-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣骑之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/166/166-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/166/166-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000025',
      name: '程咬金',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144.jpg',
      wechatId: 'chengyaojin',
      featureSign: '一个字：干',
      remarks: '热烈之斧',
      gender: 0,
      tag: 'C',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '活力突击',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '功夫厨神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '华尔街大亨',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '星际陆战队',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '爱与正义',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '热烈之斧',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/144/144-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/144/144-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000026',
      name: '赵云',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107.jpg',
      wechatId: 'zhaoyun',
      featureSign: '心怀不惧，才能翱翔于天际',
      remarks: '苍天翔龙',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '引擎之心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '白执事',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '嘻哈天王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '皇家上将',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '未来纪元',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '忍●炎影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '苍天翔龙',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/107/107-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/107/107-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000027',
      name: '达摩',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/134/134.jpg',
      wechatId: 'damo',
      featureSign: '死亡面前，众生平等',
      remarks: '拳僧',
      gender: 0,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '黄金狮子座',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/134/134-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/134/134-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '大发明家',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/134/134-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/134/134-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '拳王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/134/134-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/134/134-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '拳僧',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/134/134-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/134/134-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000028',
      name: '典韦',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129.jpg',
      wechatId: 'dianwei',
      featureSign: '求求你阻止我',
      remarks: '狂战士',
      gender: 0,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '岱宗',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/129/129-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '蓝屏警告',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/129/129-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '穷奇',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/129/129-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '黄金武士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/129/129-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '狂战士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/129/129-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/129/129-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000029',
      name: '钟无艳',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/117/117.jpg',
      wechatId: 'zhongwuyan',
      featureSign: '俗说说得好，有钱男子汉，无钱汉子难',
      remarks: '野蛮之锤',
      gender: 1,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '海滩丽影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/117/117-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/117/117-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '王者之锤',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/117/117-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/117/117-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '生化警戒',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/117/117-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/117/117-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '野蛮之锤',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/117/117-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/117/117-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000030',
      name: '老夫子',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/139/139.jpg',
      wechatId: 'laofuzi',
      featureSign: '有朋友自远方来，不亦乐乎',
      remarks: '万古长明',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '功夫老勺',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/139/139-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/139/139-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣诞老人',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/139/139-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/139/139-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '潮流仙人',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/139/139-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/139/139-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '万古长明',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/139/139-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/139/139-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000031',
      name: '西施',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/523/523.jpg',
      wechatId: 'xishi',
      featureSign: '最有价值之物,给最珍贵之人',
      remarks: '幻纱之灵',
      gender: 1,
      tag: 'X',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '归虚梦演',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/523/523-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/523/523-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '幻纱之灵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/523/523-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/523/523-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000032',
      name: '嫦娥',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/515/515.jpg',
      wechatId: 'change',
      featureSign: '夜晚的太阳，保护属于它的人。',
      remarks: '寒月公主',
      gender: 1,
      tag: 'C',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '如梦令',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/515/515-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/515/515-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '露花倒影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/515/515-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/515/515-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '寒月公主',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/515/515-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/515/515-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000033',
      name: '上官婉儿',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/513/513.jpg',
      wechatId: 'shangguanwaner',
      featureSign: '上通自然之性,下取万类之象',
      remarks: '惊鸿之笔',
      gender: 1,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '梁祝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/513/513-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/513/513-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '修竹墨客',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/513/513-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/513/513-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '惊鸿之笔',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/513/513-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/513/513-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000034',
      name: '沈梦溪',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/312/312.jpg',
      wechatId: 'shenmengxi',
      featureSign: '没人能在喵的暴躁节奏里战胜本猫。',
      remarks: '爆弹怪猫',
      gender: 1,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '星空之诺',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/312/312-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/312/312-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鲨炮海盗猫',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/312/312-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/312/312-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '棒球奇才',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/312/312-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/312/312-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '爆弹怪猫',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/312/312-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/312/312-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000035',
      name: '司马懿',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/137/137.jpg',
      wechatId: 'simayi',
      featureSign: '喜欢黑色吗',
      remarks: '寂灭之心',
      gender: 0,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '魇语军师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/137/137-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/137/137-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '寂灭之心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/137/137-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/137/137-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000036',
      name: '米莱狄',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/504/504.jpg',
      wechatId: 'milaidi',
      featureSign: '世界是我的意志，机关为我的表象',
      remarks: '筑城者',
      gender: 1,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '御霄',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/504/504-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/504/504-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '精准探案法',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/504/504-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/504/504-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '筑城者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/504/504-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/504/504-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000037',
      name: '女娲',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/179/179.jpg',
      wechatId: 'nvwa',
      featureSign: '当历史只剩罪恶 只有推倒重来',
      remarks: '至高创世',
      gender: 1,
      tag: 'N',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '朔望之晖',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/179/179-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/179/179-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '尼罗河女神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/179/179-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/179/179-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '至高创世',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/179/179-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/179/179-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000038',
      name: '梦奇',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/198/198.jpg',
      wechatId: 'mengqi',
      featureSign: '咕呼~',
      remarks: '入梦之灵',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '胖达荣荣',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/198/198-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/198/198-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '美梦成真',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/198/198-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/198/198-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '入梦之灵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/198/198-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/198/198-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000039',
      name: '干将莫邪',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/182/182.jpg',
      wechatId: 'ganjiangmoye',
      featureSign: '最好的剑，永远是下一把。',
      remarks: '淬命双剑',
      gender: 0,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '久胜战神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/182/182-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/182/182-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冰霜恋舞曲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/182/182-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/182/182-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '第七人偶',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/182/182-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/182/182-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '淬命双剑',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/182/182-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/182/182-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000040',
      name: '奕星',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/197/197.jpg',
      wechatId: 'yixing',
      featureSign: '纵横十九道内的 是无穷宇宙',
      remarks: '天元之奕',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '混沌棋',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/197/197-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/197/197-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '踏雪寻梅',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/197/197-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/197/197-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天元之奕',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/197/197-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/197/197-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000041',
      name: '诸葛亮',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190.jpg',
      wechatId: 'zhugeliang',
      featureSign: '运筹帷幄之中 决胜千里之外',
      remarks: '绝代智谋',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '掌控之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/190/190-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '武陵仙君',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/190/190-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '黄金分割率',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/190/190-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '星航指挥官',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/190/190-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '绝代智谋',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/190/190-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/190/190-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000042',
      name: '不知火舞',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/157/157.jpg',
      wechatId: 'buzhihuowu',
      featureSign: 'りゅうえんぶ',
      remarks: '明媚烈焰',
      gender: 1,
      tag: 'B',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '魅语',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/157/157-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/157/157-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '明媚烈焰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/157/157-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/157/157-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000043',
      name: '杨玉环',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/176/176.jpg',
      wechatId: 'yangyuhuan',
      featureSign: '人家是绿茶，你就像热水，想泡吗?',
      remarks: '霓裳风华',
      gender: 1,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '遇见飞天',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/176/176-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/176/176-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '霓裳曲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/176/176-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/176/176-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '霓裳风华',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/176/176-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/176/176-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000044',
      name: '貂蝉',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141.jpg',
      wechatId: 'diaochan',
      featureSign: '想欣赏妾身的舞姿吗',
      remarks: '爵士舞姬',
      gender: 1,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '猫影幻舞',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逐梦之音',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '仲夏夜之梦',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣诞恋歌',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '异域舞娘',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '爵士舞姬',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/141/141-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/141/141-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000045',
      name: '孙膑',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118.jpg',
      wechatId: 'sunbin',
      featureSign: '嘀嗒～嘀嗒～嘀嗒～嘀嗒～',
      remarks: '逆流之时',
      gender: 1,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '归虚梦演',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/118/118-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '妖精王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/118/118-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天使之翼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/118/118-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '未来旅行',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/118/118-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逆流之时',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/118/118-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/118/118-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000046',
      name: '芈月',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121.jpg',
      wechatId: 'miyue',
      featureSign: '整容手术都是骗人的，青春美貌全靠把你吸干',
      remarks: '永恒之月',
      gender: 1,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '重明',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/121/121-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '大秦宣太后',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/121/121-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '红桃皇后',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/121/121-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '永恒之月',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/121/121-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/121/121-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000047',
      name: '周瑜',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/124/124.jpg',
      wechatId: 'zhouyu',
      featureSign: '没有欲望何来胜利',
      remarks: '铁血都督',
      gender: 1,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '赤莲之焰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/124/124-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/124/124-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '真爱至上',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/124/124-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/124/124-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '海军大将',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/124/124-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/124/124-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '铁血都督',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/124/124-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/124/124-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000048',
      name: '墨子',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108.jpg',
      wechatId: 'mozi',
      featureSign: '生存就是最谨慎的战斗',
      remarks: '和平守望',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '进击墨子号',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/108/108-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '龙骑士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/108/108-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '金属风暴',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/108/108-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '和平守望',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/108/108-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/108/108-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000049',
      name: '张良',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156.jpg',
      wechatId: 'zhangliang',
      featureSign: '好奇心会害死猫',
      remarks: '言灵之书',
      gender: 1,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '黄金白羊座',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/156/156-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '幽兰居士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/156/156-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '一千零一夜',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/156/156-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天堂福音',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/156/156-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '言灵之书',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/156/156-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/156/156-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000050',
      name: '安琪拉',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142.jpg',
      wechatId: 'anqila',
      featureSign: '萝莉身，御姐心',
      remarks: '暗夜萝莉',
      gender: 1,
      tag: 'A',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '如懿',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/142/142-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '心灵骇客',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/142/142-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '魔法小厨娘',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/142/142-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '玩偶对对碰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/142/142-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暗夜萝莉',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/142/142-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/142/142-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000051',
      name: '高渐离',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/115/115.jpg',
      wechatId: 'gaojianli',
      featureSign: '动起来，鲜花会为你开',
      remarks: '叛逆游吟',
      gender: 0,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '玩趣恶龙',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/115/115-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/115/115-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '死亡摇滚',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/115/115-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/115/115-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '金属狂潮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/115/115-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/115/115-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '叛逆游吟',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/115/115-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/115/115-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000052',
      name: '武则天',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136.jpg',
      wechatId: 'wuzetian',
      featureSign: '普天之下莫非王土 做女人难做女帝更难....',
      remarks: '女帝',
      gender: 1,
      tag: 'W',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '倪克斯神谕',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/136/136-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '海洋之心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/136/136-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '东方不败',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/136/136-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '女帝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/136/136-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/136/136-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000053',
      name: '甄姬',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127.jpg',
      wechatId: 'zhenji',
      featureSign: '悲伤，逆流成河',
      remarks: '洛神降临',
      gender: 1,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '幽恒',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/127/127-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '游园惊梦',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/127/127-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '花好人间',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/127/127-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冰雪圆舞曲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/127/127-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '洛神降临',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/127/127-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/127/127-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000054',
      name: '姜子牙',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/148/148.jpg',
      wechatId: 'jiangziya',
      featureSign: '强者生，弱者死',
      remarks: '太古魔导',
      gender: 0,
      tag: 'J',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '炽热元素使',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/148/148-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/148/148-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '时尚教父',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/148/148-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/148/148-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '太古魔导',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/148/148-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/148/148-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000055',
      name: '猪八戒',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/511/511.jpg',
      wechatId: 'zhubajie',
      featureSign: '心中乾坤在 地上有西瓜',
      remarks: '无忧猛士',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '年年有余',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/511/511-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/511/511-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '无忧猛士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/511/511-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/511/511-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000056',
      name: '东皇太一',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/187/187.jpg',
      wechatId: 'donghuangtaiyi',
      featureSign: '比黑暗，更深沉的黑暗，辉映着永恒。',
      remarks: '噬灭日蚀',
      gender: 0,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '逐梦之光',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/187/187-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/187/187-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '东海龙王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/187/187-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/187/187-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '噬灭日蚀',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/187/187-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/187/187-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000057',
      name: '太乙真人',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186.jpg',
      wechatId: 'taiyizhenren',
      featureSign: '道生一，一生二！',
      remarks: '炼金大师',
      gender: 0,
      tag: 'T',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '华丽摇滚',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/186/186-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '饕餮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/186/186-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圆桌骑士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/186/186-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '炼金大师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/186/186-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/186/186-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000058',
      name: '刘邦',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/149/149.jpg',
      wechatId: 'liubang',
      featureSign: '不客观的说，我是个好人',
      remarks: '双面君主',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '夺宝奇兵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/149/149-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/149/149-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '德古拉伯爵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/149/149-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/149/149-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '圣殿之光',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/149/149-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/149/149-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '双面君主',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/149/149-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/149/149-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000059',
      name: '张飞',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/171/171.jpg',
      wechatId: 'zhangfei',
      featureSign: '英雄就是比普通人更变态的变态',
      remarks: '禁血狂兽',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '乱世虎臣',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/171/171-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/171/171-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '五福同心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/171/171-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/171/171-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '禁血狂兽',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/171/171-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/171/171-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000060',
      name: '牛魔',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168.jpg',
      wechatId: 'niumo',
      featureSign: '牛气冲天，纯爷们',
      remarks: '精英酋长',
      gender: 0,
      tag: 'N',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '御旌',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/168/168-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '制霸全明星',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/168/168-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '西部大镖客',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/168/168-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '精英酋长',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/168/168-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/168/168-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000061',
      name: '白起',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/120/120.jpg',
      wechatId: 'baiqi',
      featureSign: '血浓于血',
      remarks: '最终兵器',
      gender: 0,
      tag: 'B',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '星夜王子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/120/120-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/120/120-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '狰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/120/120-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/120/120-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '白色死神',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/120/120-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/120/120-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '最终兵器',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/120/120-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/120/120-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000062',
      name: '刘禅',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114.jpg',
      wechatId: 'liushan',
      featureSign: '蓉城小霸王，威力无穷',
      remarks: '暴走机关',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '天才门将',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/114/114-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '绅士熊喵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/114/114-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '英喵野望',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/114/114-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暴走机关',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/114/114-smallskin-1.jpg.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/114/114-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000063',
      name: '庄周',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113.jpg',
      wechatId: 'zhuangzhou',
      featureSign: '蝴蝶是我，我就是蝴蝶',
      remarks: '逍遥梦幻',
      gender: 0,
      tag: 'Z',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '玄嵩',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '奇妙博物学',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '云端筑梦师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '蜃楼王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鲤鱼之梦',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逍遥梦幻',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/113/113-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/113/113-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000064',
      name: '廉颇',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/105/105.jpg',
      wechatId: 'lianpo',
      featureSign: '要硬上吗，正合我意',
      remarks: '正义爆轰',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '地狱岩魂',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/105/105-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/105/105-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '正义爆轰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/105/105-smallskin-1.jpg.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/105/105-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000065',
      name: '项羽',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135.jpg',
      wechatId: 'xiangyu',
      featureSign: '天不容我，我必逆天',
      remarks: '霸王防脱',
      gender: 0,
      tag: 'X',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '科学大爆炸',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '霸王别姬',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '职棒王牌',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '海滩派对',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '苍穹之光',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '帝国元帅',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '霸王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/135/135-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/135/135-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000066',
      name: '元歌',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/125/125.jpg',
      wechatId: 'yuange',
      featureSign: '用头脑，而不是武力。',
      remarks: '无间傀儡',
      gender: 1,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '午夜歌剧院',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/125/125-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/125/125-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '无间傀儡',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/125/125-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/125/125-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000067',
      name: '百里玄策',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/195/195.jpg',
      wechatId: 'bailixuance',
      featureSign: '全场醒目担当！',
      remarks: '嚣狂之镰',
      gender: 0,
      tag: 'B',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '白虎志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/195/195-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/195/195-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '威尼斯狂欢',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/195/195-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/195/195-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '嚣狂之镰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/195/195-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/195/195-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000068',
      name: '裴擒虎',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/502/502.jpg',
      wechatId: 'peiqinhu',
      featureSign: '会牵挂的叫亲人，会回去的是故乡',
      remarks: '六合虎拳',
      gender: 0,
      tag: 'P',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '天狼狩猎者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/502/502-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/502/502-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '梅西',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/502/502-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/502/502-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '街头旋风',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/502/502-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/502/502-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '六合虎拳',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/502/502-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/502/502-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000069',
      name: '百里守约',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/196/196.jpg',
      wechatId: 'bailishouyue',
      featureSign: '简单，但很极致；守约，言出必果。',
      remarks: '静谧之眼',
      gender: 0,
      tag: 'B',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '朱雀志',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/196/196-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/196/196-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '特工魅影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/196/196-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/196/196-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '绝影神枪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/196/196-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/196/196-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '静谧之眼',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/196/196-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/196/196-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000070',
      name: '李白',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131.jpg',
      wechatId: 'libai',
      featureSign: '可以赶尽，无法杀绝。',
      remarks: '青莲剑仙',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '敏锐之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/131/131-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '凤求凰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/131/131-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '千年之狐',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/131/131-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '范海辛',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/131/131-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '青莲剑仙',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/131/131-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/131/131-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000071',
      name: '娜可露露',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/162/162.jpg',
      wechatId: 'nakelulu',
      featureSign: 'ありがとう、ママハハ',
      remarks: '鹰之守护',
      gender: 1,
      tag: 'N',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '晚萤',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/162/162-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/162/162-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鹰之守护',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/162/162-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/162/162-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000072',
      name: '艾琳',
      avatarUrl:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1584764149241&di=d449232dd6b524ec92c64b6b8e2280a7&imgtype=0&src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn10%2F404%2Fw592h612%2F20180410%2F5145-fyvtmxe8715392.jpg',
      wechatId: 'ailin',
      featureSign: '记住，你的未来只能属于我',
      remarks: '精灵之弓',
      gender: 1,
      tag: 'A',
      pictures: <FlutterWechatFullPicture>[],
    ),
    FlutterWechatFullContact(
      id: '10000073',
      name: '兰陵王',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/153/153.jpg',
      wechatId: 'lanlingwang',
      featureSign: '我为黑暗服务',
      remarks: '暗影刀锋',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '驯魔猎人',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/153/153-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/153/153-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暗隐猎兽者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/153/153-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/153/153-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '隐刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/153/153-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/153/153-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暗影刀锋',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/153/153-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/153/153-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000074',
      name: '阿珂',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116.jpg',
      wechatId: 'ake',
      featureSign: '不知道你的名字，但清楚你的死期',
      remarks: '信念之刃',
      gender: 1,
      tag: 'A',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '迷踪丽影',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '节奏热浪',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '致命风华',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暗夜猫娘',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '爱心护理',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '信念之刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/116/116-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/116/116-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000075',
      name: '伽罗',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/508/508.jpg',
      wechatId: 'jialuo',
      featureSign: '千窟唯佑，太平无忧',
      remarks: '破魔之箭',
      gender: 1,
      tag: 'J',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '太华',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/508/508-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/508/508-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '箭羽风息',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/508/508-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/508/508-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '花见巫女',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/508/508-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/508/508-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '破魔之箭',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/508/508-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/508/508-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000076',
      name: '公孙离',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199.jpg',
      wechatId: 'gongsunli',
      featureSign: '来如雷霆，大如江海',
      remarks: '幻舞玲珑',
      gender: 1,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '无限星赏官',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/199/199-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '蜜橘之夏',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/199/199-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '花间舞',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/199/199-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '幻舞玲珑',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/199/199-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/199/199-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000077',
      name: '黄忠',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/192/192.jpg',
      wechatId: 'huangzhong',
      featureSign: '老兵不死，只会逐渐凋零',
      remarks: '燃魂重炮',
      gender: 0,
      tag: 'H',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '芝加哥教父',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/192/192-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/192/192-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '燃魂重炮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/192/192-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/192/192-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000078',
      name: '成吉思汗',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/177/177.jpg',
      wechatId: 'chengjisihan',
      featureSign: '选择堕落为野兽吗',
      remarks: '苍狼末裔',
      gender: 0,
      tag: 'C',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '维京掠夺者',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/177/177-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/177/177-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '苍狼末裔',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/177/177-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/177/177-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000079',
      name: '马可波罗',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/132/132.jpg',
      wechatId: 'makeboluo',
      featureSign: '世界那么大，我想来看看',
      remarks: '远游之轮',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '逐梦之星',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/132/132-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/132/132-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '激情绿茵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/132/132-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/132/132-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '远游之轮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/132/132-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/132/132-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000080',
      name: '虞姬',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174.jpg',
      wechatId: 'yuji',
      featureSign: '风会带走你曾经存在过的证明。',
      remarks: '森之风灵',
      gender: 1,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '云霓雀翎',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/174/174-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '凯尔特女王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/174/174-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '霸王别姬',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/174/174-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '加勒比小姐',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/174/174-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '森之风灵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/174/174-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/174/174-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000081',
      name: '李元芳',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173.jpg',
      wechatId: 'liyuanfang',
      featureSign: '秘密的密，探案的探。',
      remarks: '王都密探',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '银河之约',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/173/173-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '逐浪之夏',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/173/173-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '黑猫爱糖果',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/173/173-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '特种部队',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/173/173-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '王都密探',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/173/173-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/173/173-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000082',
      name: '后裔',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169.jpg',
      wechatId: 'houyi',
      featureSign: '最光明，最黑暗',
      remarks: '半神之弓',
      gender: 0,
      tag: 'H',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '如梦令',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '黄金射手座',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '辉光之辰',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '阿尔法小队',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '精灵王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '半神之弓',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/169/169-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/169/169-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000083',
      name: '狄仁杰',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133.jpg',
      wechatId: 'direnjie',
      featureSign: '代表法律制裁你',
      remarks: '断案大师',
      gender: 0,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '鹰眼统帅',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '阴阳师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '超时空战士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '魔术师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '锦衣卫',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '断案大师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/133/133-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/133/133-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000084',
      name: '孙尚香',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111.jpg',
      wechatId: 'sunshangxiang',
      featureSign: '大小姐驾到，通通闪开！',
      remarks: '千金重弩',
      gender: 1,
      tag: 'S',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '沉稳之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '末日机甲',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '杀手不太冷',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '蔷薇恋人',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '水果甜心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '火炮千金',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '千金重弩',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/111/111-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/111/111-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000085',
      name: '鲁班七号',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112.jpg',
      wechatId: 'lubanqihao',
      featureSign: '鲁班大师，智商二百五，膜拜，极度膜拜',
      remarks: '机关造物',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '黑桃队长',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '狮舞东方',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '星空梦想',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '电玩小子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '福禄兄弟',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '木偶奇遇记',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '机关造物',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/112/112-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/112/112-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000086',
      name: '瑶',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/505/505.jpg',
      wechatId: 'yaosen',
      featureSign: '神在白天做梦，太阳从西边升起',
      remarks: '鹿灵守心',
      gender: 1,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '森',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/505/505-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/505/505-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '鹿灵守心',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/505/505-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/505/505-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000087',
      name: '盾山',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/509/509.jpg',
      wechatId: 'dunshan',
      featureSign: '***** *****',
      remarks: '无尽之盾',
      gender: 0,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '御銮',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/509/509-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/509/509-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '极冰防御线',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/509/509-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/509/509-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '无尽之盾',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/509/509-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/509/509-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000088',
      name: '明世隐',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501.jpg',
      wechatId: 'mingshiyin',
      featureSign: '花如盛世绽放，以人心培育',
      remarks: '灵魂劫卜',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '疑决卦',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/501/501-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '虹云星官',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/501/501-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '占星师',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/501/501-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '灵魂劫卜',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/501/501-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/501/501-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000089',
      name: '鬼谷子',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/189/189.jpg',
      wechatId: 'guiguzi',
      featureSign: '挥舞太危险的武器，小心被他吞掉人生哦！',
      remarks: '万物有灵',
      gender: 0,
      tag: 'G',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '幻乐之宴',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/189/189-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/189/189-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '阿摩司公爵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/189/189-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/189/189-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '万物有灵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/189/189-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/189/189-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000090',
      name: '大乔',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191.jpg',
      wechatId: 'daqiao',
      featureSign: '完美，是最无情的禁锢！',
      remarks: '沧海之曜',
      gender: 1,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '白蛇',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/191/191-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '猫狗日记',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/191/191-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '守护之力',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/191/191-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '伊势巫女',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/191/191-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '沧海之曜',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/191/191-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/191/191-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000091',
      name: '蔡文姬',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184.jpg',
      wechatId: 'caiwenji',
      featureSign: '左三圈~右三圈~扭一扭转一转~人家也作萝莉控~',
      remarks: '天籁弦音',
      gender: 1,
      tag: 'C',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '繁星吟游',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/184/184-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '舞动绿茵',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/184/184-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '奇迹圣诞',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/184/184-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '蔷薇王座',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/184/184-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天籁弦音',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/184/184-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/184/184-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000092',
      name: '嬴政',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110.jpg',
      wechatId: 'yingzheng',
      featureSign: '天上天下，唯朕独尊',
      remarks: '王者独尊',
      gender: 0,
      tag: 'Y',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '白昼王子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/110/110-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '优雅恋人',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/110/110-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '暗夜贵公子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/110/110-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '摇滚巨星',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/110/110-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '王者独尊',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/110/110-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/110/110-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000093',
      name: '妲己',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109.jpg',
      wechatId: 'daji',
      featureSign: '为什么会痛苦，一直微笑就好了',
      remarks: '魅力之狐',
      gender: 1,
      tag: 'D',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '时之彼端',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '热情桑巴',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '少女阿狸',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '仙境爱丽丝',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '魅力维加斯',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '女仆咖啡',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '魅力之狐',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/109/109-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/109/109-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000094',
      name: '扁鹊',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119.jpg',
      wechatId: 'bianque',
      featureSign: '命不是廉价品，治疗很昂贵',
      remarks: '善恶怪医',
      gender: 0,
      tag: 'B',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '炼金王',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/119/119-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '化身博士',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/119/119-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '救世之瞳',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/119/119-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '善恶怪医',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/119/119-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/119/119-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000095',
      name: '小乔',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106.jpg',
      wechatId: 'xiaoqiao',
      featureSign: '恋爱可是门高深莫测的学问',
      remarks: '恋之微风',
      gender: 1,
      tag: 'X',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '青蛇',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-7.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-7.jpg',
        ),
        FlutterWechatFullPicture(
          name: '丁香结',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-6.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-6.jpg',
        ),
        FlutterWechatFullPicture(
          name: '缤纷独角兽',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '纯白花嫁',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '天鹅之梦',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '万圣前夜',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '恋之微风',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/106/106-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/106/106-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000096',
      name: '王昭君',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152.jpg',
      wechatId: 'wangzhaojun',
      featureSign: '凛冬已至，故乡的梅花开了吗？',
      remarks: '冰雪之华',
      gender: 1,
      tag: 'W',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '幻想奇妙夜',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152-smallskin-5.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/152/152-bigskin-5.jpg',
        ),
        FlutterWechatFullPicture(
          name: '凤凰于飞',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152-smallskin-4.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/152/152-bigskin-4.jpg',
        ),
        FlutterWechatFullPicture(
          name: '偶像歌手',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152-smallskin-3.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/152/152-bigskin-3.jpg',
        ),
        FlutterWechatFullPicture(
          name: '精灵公主',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/152/152-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '冰雪之华',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/152/152-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/152/152-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000097',
      name: '鲁班大师',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/525/525.jpg',
      wechatId: 'lubandashi',
      featureSign: '你的无知，无边无际',
      remarks: '神匠',
      gender: 0,
      tag: 'L',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '归虚梦演',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/525/525-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/525/525-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '神匠',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/525/525-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/525/525-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000098',
      name: '蒙犽',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/524/524.jpg',
      wechatId: 'mengya',
      featureSign: '情绪调配，火力翻倍',
      remarks: '烈炮小子',
      gender: 0,
      tag: 'M',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '归虚梦演',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/524/524-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/524/524-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '烈炮小子',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/524/524-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/524/524-bigskin-1.jpg',
        ),
      ],
    ),
    FlutterWechatFullContact(
      id: '10000099',
      name: '镜',
      avatarUrl:
          'https://game.gtimg.cn/images/yxzj/img201606/heroimg/531/531.jpg',
      wechatId: 'jing',
      featureSign: '不要忘记不该忘的事，不要记住不该记的人。',
      remarks: '破镜之刃',
      gender: 1,
      tag: 'J',
      pictures: <FlutterWechatFullPicture>[
        FlutterWechatFullPicture(
          name: '冰刃幻境',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/531/531-smallskin-2.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/531/531-bigskin-2.jpg',
        ),
        FlutterWechatFullPicture(
          name: '破镜之刃',
          smallUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/heroimg/531/531-smallskin-1.jpg',
          bigUrl:
              'https://game.gtimg.cn/images/yxzj/img201606/skin/hero-info/531/531-bigskin-1.jpg',
        ),
      ],
    ),
  ];

  /// Country / region codes (`mock/world_zone_code.json`) in file order.
  static const List<FlutterWechatFullZoneCode>
  zoneCodes = <FlutterWechatFullZoneCode>[
    FlutterWechatFullZoneCode('AD', '安道尔共和国', 'Andorra', '376', 'A'),
    FlutterWechatFullZoneCode(
      'AE',
      '阿拉伯联合酋长国',
      'UnitedArabEmirates',
      '971',
      'A',
    ),
    FlutterWechatFullZoneCode('AF', '阿富汗', 'Afghanistan', '93', 'A'),
    FlutterWechatFullZoneCode(
      'AG',
      '安提瓜和巴布达',
      'AntiguaandBarbuda',
      '1268',
      'A',
    ),
    FlutterWechatFullZoneCode('AI', '安圭拉岛', 'Anguilla', '1264', 'A'),
    FlutterWechatFullZoneCode('AL', '阿尔巴尼亚', 'Albania', '355', 'A'),
    FlutterWechatFullZoneCode('AM', '阿美尼亚', 'Armenia', '374', 'A'),
    FlutterWechatFullZoneCode('', '阿森松', 'Ascension', '247', 'A'),
    FlutterWechatFullZoneCode('AO', '安哥拉', 'Angola', '244', 'A'),
    FlutterWechatFullZoneCode('AR', '阿根廷', 'Argentina', '54', 'A'),
    FlutterWechatFullZoneCode('AT', '奥地利', 'Austria', '43', 'A'),
    FlutterWechatFullZoneCode('AU', '澳大利亚', 'Australia', '61', 'A'),
    FlutterWechatFullZoneCode('AZ', '阿塞拜疆', 'Azerbaijan', '994', 'A'),
    FlutterWechatFullZoneCode('BB', '巴巴多斯', 'Barbados', '1246', 'B'),
    FlutterWechatFullZoneCode('BD', '孟加拉国', 'Bangladesh', '880', 'M'),
    FlutterWechatFullZoneCode('BE', '比利时', 'Belgium', '32', 'B'),
    FlutterWechatFullZoneCode('BF', '布基纳法索', 'Burkina-faso', '226', 'B'),
    FlutterWechatFullZoneCode('BG', '保加利亚', 'Bulgaria', '359', 'B'),
    FlutterWechatFullZoneCode('BH', '巴林', 'Bahrain', '973', 'B'),
    FlutterWechatFullZoneCode('BI', '布隆迪', 'Burundi', '257', 'B'),
    FlutterWechatFullZoneCode('BJ', '贝宁', 'Benin', '229', 'B'),
    FlutterWechatFullZoneCode('BL', '巴勒斯坦', 'Palestine', '970', 'B'),
    FlutterWechatFullZoneCode('BM', '百慕大群岛', 'BermudaIs.', '1441', 'B'),
    FlutterWechatFullZoneCode('BN', '文莱', 'Brunei', '673', 'W'),
    FlutterWechatFullZoneCode('BO', '玻利维亚', 'Bolivia', '591', 'B'),
    FlutterWechatFullZoneCode('BR', '巴西', 'Brazil', '55', 'B'),
    FlutterWechatFullZoneCode('BS', '巴哈马', 'Bahamas', '1242', 'B'),
    FlutterWechatFullZoneCode('BW', '博茨瓦纳', 'Botswana', '267', 'B'),
    FlutterWechatFullZoneCode('BY', '白俄罗斯', 'Belarus', '375', 'B'),
    FlutterWechatFullZoneCode('BZ', '伯利兹', 'Belize', '501', 'B'),
    FlutterWechatFullZoneCode('CA', '加拿大', 'Canada', '1', 'J'),
    FlutterWechatFullZoneCode('', '开曼群岛', 'CaymanIs.', '1345', 'K'),
    FlutterWechatFullZoneCode(
      'CF',
      '中非共和国',
      'CentralAfricanRepublic',
      '236',
      'Z',
    ),
    FlutterWechatFullZoneCode('CG', '刚果', 'Congo', '242', 'G'),
    FlutterWechatFullZoneCode('CH', '瑞士', 'Switzerland', '41', 'R'),
    FlutterWechatFullZoneCode('CK', '库克群岛', 'CookIs.', '682', 'K'),
    FlutterWechatFullZoneCode('CL', '智利', 'Chile', '56', 'Z'),
    FlutterWechatFullZoneCode('CM', '喀麦隆', 'Cameroon', '237', 'K'),
    FlutterWechatFullZoneCode('CN', '中国大陆', 'China', '86', 'Z'),
    FlutterWechatFullZoneCode('CO', '哥伦比亚', 'Colombia', '57', 'G'),
    FlutterWechatFullZoneCode('CR', '哥斯达黎加', 'CostaRica', '506', 'G'),
    FlutterWechatFullZoneCode('CS', '捷克', 'Czech', '420', 'J'),
    FlutterWechatFullZoneCode('CU', '古巴', 'Cuba', '53', 'G'),
    FlutterWechatFullZoneCode('CY', '塞浦路斯', 'Cyprus', '357', 'S'),
    FlutterWechatFullZoneCode('CZ', '捷克', 'CzechRepublic', '420', 'J'),
    FlutterWechatFullZoneCode('DE', '德国', 'Germany', '49', 'D'),
    FlutterWechatFullZoneCode('DJ', '吉布提', 'Djibouti', '253', 'J'),
    FlutterWechatFullZoneCode('DK', '丹麦', 'Denmark', '45', 'D'),
    FlutterWechatFullZoneCode('DO', '多米尼加共和国', 'DominicaRep.', '1890', 'D'),
    FlutterWechatFullZoneCode('DZ', '阿尔及利亚', 'Algeria', '213', 'A'),
    FlutterWechatFullZoneCode('EC', '厄瓜多尔', 'Ecuador', '593', 'E'),
    FlutterWechatFullZoneCode('EE', '爱沙尼亚', 'Estonia', '372', 'A'),
    FlutterWechatFullZoneCode('EG', '埃及', 'Egypt', '20', 'E'),
    FlutterWechatFullZoneCode('ES', '西班牙', 'Spain', '34', 'X'),
    FlutterWechatFullZoneCode('ET', '埃塞俄比亚', 'Ethiopia', '251', 'A'),
    FlutterWechatFullZoneCode('FI', '芬兰', 'Finland', '358', 'F'),
    FlutterWechatFullZoneCode('FJ', '斐济', 'Fiji', '679', 'F'),
    FlutterWechatFullZoneCode('FR', '法国', 'France', '33', 'F'),
    FlutterWechatFullZoneCode('GA', '加蓬', 'Gabon', '241', 'J'),
    FlutterWechatFullZoneCode('GB', '英国', 'UnitedKiongdom', '44', 'Y'),
    FlutterWechatFullZoneCode('GD', '格林纳达', 'Grenada', '1809', 'G'),
    FlutterWechatFullZoneCode('GE', '格鲁吉亚', 'Georgia', '995', 'G'),
    FlutterWechatFullZoneCode('GF', '法属圭亚那', 'FrenchGuiana', '594', 'F'),
    FlutterWechatFullZoneCode('GH', '加纳', 'Ghana', '233', 'J'),
    FlutterWechatFullZoneCode('GI', '直布罗陀', 'Gibraltar', '350', 'Z'),
    FlutterWechatFullZoneCode('GM', '冈比亚', 'Gambia', '220', 'G'),
    FlutterWechatFullZoneCode('GN', '几内亚', 'Guinea', '224', 'J'),
    FlutterWechatFullZoneCode('GR', '希腊', 'Greece', '30', 'X'),
    FlutterWechatFullZoneCode('GT', '危地马拉', 'Guatemala', '502', 'W'),
    FlutterWechatFullZoneCode('GU', '关岛', 'Guam', '1671', 'G'),
    FlutterWechatFullZoneCode('GY', '圭亚那', 'Guyana', '592', 'G'),
    FlutterWechatFullZoneCode('HK', '香港(中国)', 'Hongkong', '852', 'X'),
    FlutterWechatFullZoneCode('HN', '洪都拉斯', 'Honduras', '504', 'H'),
    FlutterWechatFullZoneCode('HT', '海地', 'Haiti', '509', 'H'),
    FlutterWechatFullZoneCode('HU', '匈牙利', 'Hungary', '36', 'X'),
    FlutterWechatFullZoneCode('ID', '印度尼西亚', 'Indonesia', '62', 'Y'),
    FlutterWechatFullZoneCode('IE', '爱尔兰', 'Ireland', '353', 'A'),
    FlutterWechatFullZoneCode('IL', '以色列', 'Israel', '972', 'Y'),
    FlutterWechatFullZoneCode('IN', '印度', 'India', '91', 'Y'),
    FlutterWechatFullZoneCode('IQ', '伊拉克', 'Iraq', '964', 'Y'),
    FlutterWechatFullZoneCode('IR', '伊朗', 'Iran', '98', 'Y'),
    FlutterWechatFullZoneCode('IS', '冰岛', 'Iceland', '354', 'B'),
    FlutterWechatFullZoneCode('IT', '意大利', 'Italy', '39', 'Y'),
    FlutterWechatFullZoneCode('', '科特迪瓦', 'IvoryCoast', '225', 'K'),
    FlutterWechatFullZoneCode('JM', '牙买加', 'Jamaica', '1876', 'Y'),
    FlutterWechatFullZoneCode('JO', '约旦', 'Jordan', '962', 'Y'),
    FlutterWechatFullZoneCode('JP', '日本', 'Japan', '81', 'R'),
    FlutterWechatFullZoneCode('KE', '肯尼亚', 'Kenya', '254', 'K'),
    FlutterWechatFullZoneCode('KG', '吉尔吉斯坦', 'Kyrgyzstan', '331', 'J'),
    FlutterWechatFullZoneCode('KH', '柬埔寨', 'Kampuchea(Cambodia)', '855', 'J'),
    FlutterWechatFullZoneCode('KP', '朝鲜', 'NorthKorea', '850', 'C'),
    FlutterWechatFullZoneCode('KR', '韩国', 'Korea', '82', 'H'),
    FlutterWechatFullZoneCode(
      'KT',
      '科特迪瓦共和国',
      'RepublicofIvoryCoast',
      '225',
      'K',
    ),
    FlutterWechatFullZoneCode('KW', '科威特', 'Kuwait', '965', 'K'),
    FlutterWechatFullZoneCode('KZ', '哈萨克斯坦', 'Kazakstan', '327', 'H'),
    FlutterWechatFullZoneCode('LA', '老挝', 'Laos', '856', 'L'),
    FlutterWechatFullZoneCode('LB', '黎巴嫩', 'Lebanon', '961', 'L'),
    FlutterWechatFullZoneCode('LC', '圣卢西亚', 'St.Lucia', '1758', 'S'),
    FlutterWechatFullZoneCode('LI', '列支敦士登', 'Liechtenstein', '423', 'L'),
    FlutterWechatFullZoneCode('LK', '斯里兰卡', 'SriLanka', '94', 'S'),
    FlutterWechatFullZoneCode('LR', '利比里亚', 'Liberia', '231', 'L'),
    FlutterWechatFullZoneCode('LS', '莱索托', 'Lesotho', '266', 'L'),
    FlutterWechatFullZoneCode('LT', '立陶宛', 'Lithuania', '370', 'L'),
    FlutterWechatFullZoneCode('LU', '卢森堡', 'Luxembourg', '352', 'L'),
    FlutterWechatFullZoneCode('LV', '拉脱维亚', 'Latvia', '371', 'L'),
    FlutterWechatFullZoneCode('LY', '利比亚', 'Libya', '218', 'L'),
    FlutterWechatFullZoneCode('MA', '摩洛哥', 'Morocco', '212', 'M'),
    FlutterWechatFullZoneCode('MC', '摩纳哥', 'Monaco', '377', 'M'),
    FlutterWechatFullZoneCode('MD', '摩尔多瓦', 'Moldova,Republicof', '373', 'M'),
    FlutterWechatFullZoneCode('MG', '马达加斯加', 'Madagascar', '261', 'M'),
    FlutterWechatFullZoneCode('ML', '马里', 'Mali', '223', 'M'),
    FlutterWechatFullZoneCode('MM', '缅甸', 'Burma', '95', 'M'),
    FlutterWechatFullZoneCode('MN', '蒙古', 'Mongolia', '976', 'M'),
    FlutterWechatFullZoneCode('MO', '澳门（中国）', 'Macao', '853', 'A'),
    FlutterWechatFullZoneCode('MS', '蒙特塞拉特岛', 'MontserratIs', '1664', 'M'),
    FlutterWechatFullZoneCode('MT', '马耳他', 'Malta', '356', 'M'),
    FlutterWechatFullZoneCode('', '马里亚那群岛', 'MarianaIs', '1670', 'M'),
    FlutterWechatFullZoneCode('', '马提尼克', 'Martinique', '596', 'M'),
    FlutterWechatFullZoneCode('MU', '毛里求斯', 'Mauritius', '230', 'M'),
    FlutterWechatFullZoneCode('MV', '马尔代夫', 'Maldives', '960', 'M'),
    FlutterWechatFullZoneCode('MW', '马拉维', 'Malawi', '265', 'M'),
    FlutterWechatFullZoneCode('MX', '墨西哥', 'Mexico', '52', 'M'),
    FlutterWechatFullZoneCode('MY', '马来西亚', 'Malaysia', '60', 'M'),
    FlutterWechatFullZoneCode('MZ', '莫桑比克', 'Mozambique', '258', 'M'),
    FlutterWechatFullZoneCode('NA', '纳米比亚', 'Namibia', '264', 'N'),
    FlutterWechatFullZoneCode('NE', '尼日尔', 'Niger', '977', 'N'),
    FlutterWechatFullZoneCode('NG', '尼日利亚', 'Nigeria', '234', 'N'),
    FlutterWechatFullZoneCode('NI', '尼加拉瓜', 'Nicaragua', '505', 'N'),
    FlutterWechatFullZoneCode('NL', '荷兰', 'Netherlands', '31', 'H'),
    FlutterWechatFullZoneCode('NO', '挪威', 'Norway', '47', 'N'),
    FlutterWechatFullZoneCode('NP', '尼泊尔', 'Nepal', '977', 'N'),
    FlutterWechatFullZoneCode('', '荷属安的列斯', 'NetheriandsAntilles', '599', 'H'),
    FlutterWechatFullZoneCode('NR', '瑙鲁', 'Nauru', '674', 'N'),
    FlutterWechatFullZoneCode('NZ', '新西兰', 'NewZealand', '64', 'X'),
    FlutterWechatFullZoneCode('OM', '阿曼', 'Oman', '968', 'A'),
    FlutterWechatFullZoneCode('PA', '巴拿马', 'Panama', '507', 'B'),
    FlutterWechatFullZoneCode('PE', '秘鲁', 'Peru', '51', 'B'),
    FlutterWechatFullZoneCode('PF', '法属玻利尼西亚', 'FrenchPolynesia', '689', 'F'),
    FlutterWechatFullZoneCode('PG', '巴布亚新几内亚', 'PapuaNewCuinea', '675', 'B'),
    FlutterWechatFullZoneCode('PH', '菲律宾', 'Philippines', '63', 'F'),
    FlutterWechatFullZoneCode('PK', '巴基斯坦', 'Pakistan', '92', 'B'),
    FlutterWechatFullZoneCode('PL', '波兰', 'Poland', '48', 'B'),
    FlutterWechatFullZoneCode('PR', '波多黎各', 'PuertoRico', '1787', 'B'),
    FlutterWechatFullZoneCode('PT', '葡萄牙', 'Portugal', '351', 'P'),
    FlutterWechatFullZoneCode('PY', '巴拉圭', 'Paraguay', '595', 'B'),
    FlutterWechatFullZoneCode('QA', '卡塔尔', 'Qatar', '974', 'K'),
    FlutterWechatFullZoneCode('', '留尼旺', 'Reunion', '262', 'L'),
    FlutterWechatFullZoneCode('RO', '罗马尼亚', 'Romania', '40', 'L'),
    FlutterWechatFullZoneCode('RU', '俄罗斯', 'Russia', '7', 'E'),
    FlutterWechatFullZoneCode('SA', '沙特阿拉伯', 'SaudiArabia', '966', 'S'),
    FlutterWechatFullZoneCode('SB', '所罗门群岛', 'SolomonIs', '677', 'S'),
    FlutterWechatFullZoneCode('SC', '塞舌尔', 'Seychelles', '248', 'S'),
    FlutterWechatFullZoneCode('SD', '苏丹', 'Sudan', '249', 'S'),
    FlutterWechatFullZoneCode('SE', '瑞典', 'Sweden', '46', 'R'),
    FlutterWechatFullZoneCode('SG', '新加坡', 'Singapore', '65', 'X'),
    FlutterWechatFullZoneCode('SI', '斯洛文尼亚', 'Slovenia', '386', 'S'),
    FlutterWechatFullZoneCode('SK', '斯洛伐克', 'Slovakia', '421', 'S'),
    FlutterWechatFullZoneCode('SL', '塞拉利昂', 'SierraLeone', '232', 'S'),
    FlutterWechatFullZoneCode('SM', '圣马力诺', 'SanMarino', '378', 'S'),
    FlutterWechatFullZoneCode('', '东萨摩亚(美)', 'SamoaEastern', '684', 'D'),
    FlutterWechatFullZoneCode('', '西萨摩亚', 'SanMarino', '685', 'X'),
    FlutterWechatFullZoneCode('SN', '塞内加尔', 'Senegal', '221', 'S'),
    FlutterWechatFullZoneCode('SO', '索马里', 'Somali', '252', 'S'),
    FlutterWechatFullZoneCode('SR', '苏里南', 'Suriname', '597', 'S'),
    FlutterWechatFullZoneCode(
      'ST',
      '圣多美和普林西比',
      'SaoTomeandPrincipe',
      '239',
      'S',
    ),
    FlutterWechatFullZoneCode('SV', '萨尔瓦多', 'EISalvador', '503', 'S'),
    FlutterWechatFullZoneCode('SY', '叙利亚', 'Syria', '963', 'X'),
    FlutterWechatFullZoneCode('SZ', '斯威士兰', 'Swaziland', '268', 'S'),
    FlutterWechatFullZoneCode('TD', '乍得', 'Chad', '235', 'Z'),
    FlutterWechatFullZoneCode('TG', '多哥', 'Togo', '228', 'D'),
    FlutterWechatFullZoneCode('TH', '泰国', 'Thailand', '66', 'T'),
    FlutterWechatFullZoneCode('TJ', '塔吉克斯坦', 'Tajikstan', '992', 'T'),
    FlutterWechatFullZoneCode('TM', '土库曼斯坦', 'Turkmenistan', '993', 'T'),
    FlutterWechatFullZoneCode('TN', '突尼斯', 'Tunisia', '216', 'T'),
    FlutterWechatFullZoneCode('TO', '汤加', 'Tonga', '676', 'T'),
    FlutterWechatFullZoneCode('TR', '土耳其', 'Turkey', '90', 'T'),
    FlutterWechatFullZoneCode(
      'TT',
      '特立尼达和多巴哥',
      'TrinidadandTobago',
      '1809',
      'T',
    ),
    FlutterWechatFullZoneCode('TW', '台湾（中国）', 'Taiwan', '886', 'T'),
    FlutterWechatFullZoneCode('TZ', '坦桑尼亚', 'Tanzania', '255', 'T'),
    FlutterWechatFullZoneCode('UA', '乌克兰', 'Ukraine', '380', 'W'),
    FlutterWechatFullZoneCode('UG', '乌干达', 'Uganda', '256', 'W'),
    FlutterWechatFullZoneCode('US', '美国', 'UnitedStatesofAmerica', '1', 'M'),
    FlutterWechatFullZoneCode('UY', '乌拉圭', 'Uruguay', '598', 'W'),
    FlutterWechatFullZoneCode('UZ', '乌兹别克斯坦', 'Uzbekistan', '233', 'W'),
    FlutterWechatFullZoneCode('VC', '圣文森特岛', 'SaintVincent', '1784', 'S'),
    FlutterWechatFullZoneCode('VE', '委内瑞拉', 'Venezuela', '58', 'W'),
    FlutterWechatFullZoneCode('VN', '越南', 'Vietnam', '84', 'Y'),
    FlutterWechatFullZoneCode('YE', '也门', 'Yemen', '967', 'Y'),
    FlutterWechatFullZoneCode('YU', '南斯拉夫', 'Yugoslavia', '381', 'N'),
    FlutterWechatFullZoneCode('ZA', '南非', 'SouthAfrica', '27', 'N'),
    FlutterWechatFullZoneCode('ZM', '赞比亚', 'Zambia', '260', 'Z'),
    FlutterWechatFullZoneCode('ZR', '扎伊尔', 'Zaire', '243', 'Z'),
    FlutterWechatFullZoneCode('ZW', '津巴布韦', 'Zimbabwe', '263', 'J'),
  ];

  /// Profile values from `mock/user.json`.
  static const String profileName = 'Mike-乱港三千-Mr_元先森';
  static const String profileWechatId = '微信号：codermikehe';
  static const String profileWechatIdValue = 'codermikehe';
  static const String profileSignature = '生死看淡，不服就干';
  static const String profileAvatarUrl =
      'http://tva3.sinaimg.cn/crop.0.6.264.264.180/93276e1fjw8f5c6ob1pmpj207g07jaa5.jpg';
  static const String profileQq = '491273090';
  static const String profileMailbox = '未绑定';
}
