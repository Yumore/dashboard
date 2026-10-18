import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_audio_link.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_entrance.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_comment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_message.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_min_program.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_web_page_link.dart';

/// Verbatim seed data from the source `lib/data_source.dart`.
///
/// The source app has no bundled UI images: every avatar, moments cover, audio
/// cover and mini-program icon is a remote URL. The static demo keeps those
/// strings as data for fidelity but renders deterministic local placeholders,
/// so it stays offline and the widget tests stay network-free.
class FakeWechatSeedData {
  const FakeWechatSeedData._();

  static const FakeWechatFriend user = FakeWechatFriend(
    name: '廖布斯',
    avatar:
        'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1236308033,3321919462&fm=26&gp=0.jpg',
    momentsCover:
        'https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1577093270&di=2bd3f20670a6b468b680664dda873c63&src=http://b-ssl.duitang.com/uploads/item/201709/21/20170921103932_vC4NR.jpeg',
  );

  static const List<FakeWechatFriend> friends = <FakeWechatFriend>[
    FakeWechatFriend(
      name: '梁朝伟',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668990899&di=0d6e27b2fe5b27501d6d2dc3533c5e84&imgtype=0&src=http%3A%2F%2Fpic4.zhimg.com%2F914971f36da5e150cb0a61b171f095eb_b.jpg',
    ),
    FakeWechatFriend(
      name: '长泽雅美',
      avatar:
          'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3607243162,3473478855&fm=26&gp=0.jpg',
      momentsCover:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3129531823,304476160&fm=26&gp=0.jpg',
    ),
    FakeWechatFriend(
      name: '刘德华',
      avatar:
          'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3846959827,4200674399&fm=26&gp=0.jpg',
    ),
    FakeWechatFriend(
      name: '周华健',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668751759&di=c3c34453866761c90a240068950593c1&imgtype=0&src=http%3A%2F%2Fimg.5nd.com%2F250%2FPhoto%2Fsinger%2F1%2F3039.jpg',
    ),
    FakeWechatFriend(
      name: '宇多田光',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576668699017&di=6a35e609baa061158e4a526fe3a070e2&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F201611_24_12%2Fa2hqy75949515717503.jpeg',
    ),
    FakeWechatFriend(
      name: '仓木麻衣',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669076568&di=0936f7a7ec4a3bbc7d4d10ff53b689c9&imgtype=0&src=http%3A%2F%2Fpicm.bbzhi.com%2Fmingxingbizhi%2Fcangmumayikurakimai%2Fstar_starjp_198158_m.jpg',
    ),
    FakeWechatFriend(
      name: '小栗旬',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669097850&di=55770837e42cd4c2fbbd5c1d6664ac17&imgtype=0&src=http%3A%2F%2Fztd00.photos.bdimg.com%2Fztd%2Fw%3D700%3Bq%3D50%2Fsign%3D2188551bb83533faf5b6912e98e88c22%2F562c11dfa9ec8a135b778bf5fe03918fa0ecc0b2.jpg',
    ),
    FakeWechatFriend(
      name: '金城武',
      avatar:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=282634885,4205940362&fm=26&gp=0.jpg',
    ),
    FakeWechatFriend(
      name: '张卫健',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577263926&di=07c43b047293b8e95f691cbdaa84344f&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.mp.sohu.com%2Fq_mini%2Cc_zoom%2Cw_640%2Fupload%2F20170721%2F54544c99d89a47c685ef461b5bd85a7c_th.jpg',
    ),
    FakeWechatFriend(
      name: '赵本山',
      avatar:
          'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2655657748,3681886583&fm=26&gp=0.jpg',
    ),
    FakeWechatFriend(
      name: '新垣结衣',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577264341&di=e3a569bc386d0eae544a929852597e15&imgtype=jpg&er=1&src=http%3A%2F%2Fdingyue.ws.126.net%2FhkMGnsbJGT1EkIr6zHmPS0QnlEoUxS2VCenK0BBQhDA7i1550203810262.jpg',
    ),
    FakeWechatFriend(
      name: '滨崎步',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669772412&di=67f33543d8384c9770028b66916d5032&imgtype=0&src=http%3A%2F%2Fbigtu.eastday.com%2Fimg%2F201211%2F06%2F89%2F8398021580555610609.jpg',
    ),
    FakeWechatFriend(
      name: '林青霞',
      avatar:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669741416&di=bab7afbbd07a94779b3800380624bb6a&imgtype=0&src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Frecom%2F2017%2F01%2F13%2F148429027077417546.JPEG',
    ),
  ];

  static final List<FakeWechatMinProgram> minPrograms = <FakeWechatMinProgram>[
    const FakeWechatMinProgram(
      name: '抖音',
      icon:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576472833976&di=bfc3b95448eb89321f4e25ea0fbf2054&imgtype=0&src=http%3A%2F%2Fhbimg.huabanimg.com%2Ff2b2ad85a548a22049f10f90cf32dd8cd9f79b0c90c0-gbkg5j_fw658',
      unavailableNote: FakeWechatDemoConfig.externalPageUnavailableMessage,
    ),
    const FakeWechatMinProgram(
      name: 'QQ音乐',
      icon: 'http://pic.962.net/up/2016-4/2016418917511892.png',
    ),
    const FakeWechatMinProgram(
      name: '豆瓣',
      icon: 'http://pic.962.net/up/2016-4/2016418917511892.png',
      unavailableNote: FakeWechatDemoConfig.externalPageUnavailableMessage,
    ),
    const FakeWechatMinProgram(
      name: '今日头条',
      icon:
          'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576669446398&di=1cb9308cd9645a4f434bba43d66056ea&imgtype=0&src=http%3A%2F%2Fimg1.sooshong.com%2Fpics%2F201606%2F4%2F201664223036205.jpg',
    ),
    const FakeWechatMinProgram(
      name: '微信阅读',
      icon:
          'https://rescdn.qqmail.com/node/wr/wrpage/style/images/independent/favicon/favicon_48h.png',
      unavailableNote: FakeWechatDemoConfig.externalPageUnavailableMessage,
    ),
  ];

  static final List<FakeWechatChatEntrance> chatEntrances =
      <FakeWechatChatEntrance>[
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[0],
          unreadCount: 3,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '一起拍电影吧',
            timestamp: 1000000000,
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[1],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '我要来中国了',
            timestamp: 100000000,
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[2],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '有什么电影推荐啊?',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[3],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '我是天王杀手，ok？',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[4],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '你做喜欢我的什么歌？',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[5],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '周末一起吃饭吧',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[6],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '我很帅的啊',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[7],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '我可以是日本人啊！',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[8],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '周末一起吃个饭吧',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[9],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '啥时来看二人转？',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[10],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '你喜欢我的什么呢？',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[11],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '我出新歌了，来听听吧！',
          ),
        ),
        FakeWechatChatEntrance(
          friend: FakeWechatSeedData.friends[12],
          unreadCount: 10,
          recentMessage: FakeWechatMessage(
            type: FakeWechatMessage.textType,
            text: '还记得我的电影吗？',
          ),
        ),
      ];

  /// Source `FriendListPage` item order, including the letter headers and the
  /// final contact-count integer.
  static final List<Object> contactsItems = <Object>[
    'B',
    friends[11],
    'C',
    friends[1],
    friends[5],
    'L',
    friends[0],
    friends[2],
    friends[12],
    'J',
    friends[7],
    'X',
    friends[6],
    friends[10],
    'Y',
    friends[4],
    'Z',
    friends[3],
    friends[8],
    friends[9],
    friends.length,
  ];

  /// Source `MOMENTS` order and values.
  static final List<FakeWechatMoment> moments = <FakeWechatMoment>[
    FakeWechatMoment(
      text: '我喜欢的一首歌',
      friend: friends[0],
      type: FakeWechatMoment.audioType,
      timestamp: 1000123,
      audioLink: const FakeWechatAudioLink(
        cover:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577271400447&di=35b8834221385b63377f2bdbf64b41d4&imgtype=0&src=http%3A%2F%2Fcdn.music.migu.cn%2Fpicture%2F2018%2F0412%2F1800%2FARTL1610171034331187.jpg',
        name: '回忆沙漠',
        artist: '杨宗纬',
        url:
            'https://s128.xiami.net/319/7319/33091/2079859_1504591944341.mp3?ccode=xiami_web_web&expire=86400&duration=240&psid=5d941ef50b2cde1e54c20939cb7827c9',
      ),
    ),
    FakeWechatMoment(
      text: '分享一首好听的歌',
      friend: friends[2],
      type: FakeWechatMoment.audioType,
      timestamp: 1000123,
      audioLink: const FakeWechatAudioLink(
        cover:
            'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1577873709&di=97b1734cb9ad28ad9b619901610d74ce&imgtype=jpg&er=1&src=http%3A%2F%2Fcdnmusic.migu.cn%2Fpicture%2F2017%2F1109%2F0716%2FAL1609221019437724.jpg',
        name: '你不是真正的快乐',
        artist: '五月天',
        url:
            'https://s128.xiami.net/308/2308/12362/152042_1592377026108_6224.mp3?ccode=xiami_web_web&expire=86400&duration=280',
      ),
    ),
    FakeWechatMoment(
      text: '我今天很开心',
      friend: friends[5],
      type: FakeWechatMoment.textType,
      timestamp: 1000123,
    ),
    FakeWechatMoment(
      text: '看看这个新闻',
      friend: friends[3],
      type: FakeWechatMoment.webPageType,
      timestamp: 1000123,
      webPageLink: const FakeWechatWebPageLink(
        title: '网易绝情踢员工',
        cover:
            'http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033',
        url:
            'http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc',
      ),
    ),
    FakeWechatMoment(
      text: '看看这个新闻',
      friend: friends[4],
      type: FakeWechatMoment.webPageType,
      timestamp: 1000123,
      webPageLink: const FakeWechatWebPageLink(
        title: '网易绝情踢员工',
        cover:
            'http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033',
        url:
            'http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc',
      ),
    ),
    FakeWechatMoment(
      text: '看看这个新闻',
      friend: friends[1],
      type: FakeWechatMoment.webPageType,
      timestamp: 1000123,
      webPageLink: const FakeWechatWebPageLink(
        title: '网易绝情踢员工',
        cover:
            'http://pics1.baidu.com/feed/91529822720e0cf39dbaefe79e693c1abe09aa16.jpeg?token=7ef31617682291d1ad08c5b64621db06&s=BD9A7F9540224AAEBA0828ED03003033',
        url:
            'http://baijiahao.baidu.com/s?id=1651222227934364431&wfr=spider&for=pc',
      ),
    ),
    FakeWechatMoment(
      text: '我今天很开心',
      friend: friends[0],
      type: FakeWechatMoment.imageType,
      timestamp: 1000123,
      images: const <String>[
        'http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg',
        'http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg',
        'http://b-ssl.duitang.com/uploads/item/201811/04/20181104074412_wcelx.jpg',
      ],
      comments: <FakeWechatComment>[
        FakeWechatComment('好样的', FakeWechatSeedData.friends[1]),
        FakeWechatComment('你是个人才', FakeWechatSeedData.friends[1]),
        FakeWechatComment(
          '你才是个人才',
          FakeWechatSeedData.friends[0],
          replyer: FakeWechatSeedData.friends[1],
        ),
      ],
    ),
  ];

  static int get totalUnread =>
      chatEntrances.fold<int>(0, (sum, entry) => sum + entry.unreadCount);

  static List<String> get contactLetterHeaders => contactsItems
      .whereType<String>()
      .where((item) => item.length == 1)
      .toList(growable: false);
}
