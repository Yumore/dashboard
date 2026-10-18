/// Port of the source `ContactObject` model (source
/// `lib/contacts/ContactObject.dart:7-13`).
class FlutterWechatContact {
  const FlutterWechatContact({
    required this.seationKey,
    required this.name,
    required this.avatarUrl,
  });

  /// Source field `seationKey` (sic): the A-Z / `#` section the contact sits in.
  final String seationKey;
  final String name;
  final String avatarUrl;
}

/// Port of the source `contactData` list (source
/// `lib/contacts/ContactObject.dart:15-...`), verbatim and in source order.
///
/// 52 contacts. An empty [FlutterWechatContact.avatarUrl] is preserved as an
/// empty string: the source's `ContactItem` swaps in its own fallback picture
/// for those rows, and the port keeps that decision at the same layer.
final List<FlutterWechatContact> flutterWechatContacts = <FlutterWechatContact>[
  FlutterWechatContact(
    seationKey: 'A',
    name: '阿岚',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279132&di=e3b1626597a80813e14f89c9b91eaecc&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-2%2F15184007524801649.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'A',
    name: '阿狗',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279421&di=1e088eda8012e4b01ddb66c4814afcbe&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2017-12%2F2017120417460250991.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'B',
    name: '斌哥',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279416&di=555336c90a0fc4369cdd724cf8ddb4d3&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-1%2F2018012413525170067.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'C',
    name: '陈皮',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279409&di=c04fca2322c5fd92860d5445ac67f5ba&imgtype=0&src=http%3A%2F%2Fimg.duoziwang.com%2F2018%2F07%2F201812398230049.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'C',
    name: '吃货',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279366&di=719ff45f6f437c3343dabb45aacb20e3&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2017-10%2F2017101711451141921.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'C',
    name: '踩蘑菇头',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279357&di=500225256d2dd3b45f69f07fb8565274&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2017-10%2F2017102511454453104.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'D',
    name: '杜一',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279343&di=a85a9844a259f97a0a3349ad0ca0bdfb&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2017-12%2F2017120617245278991.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'D',
    name: '东方红',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279342&di=7eae385ce6b52688ec1ae23efb6df2b6&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-2%2F2018020913274626058.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'D',
    name: '大表哥',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317279332&di=4ce7a79c1969de3afd25ff12415a9a86&imgtype=0&src=http%3A%2F%2Fimg.duoziwang.com%2F2018%2F07%2F201812398230061.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'F',
    name: '飞机',
    avatarUrl:
        'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=889175251,2001539136&fm=27&gp=0.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'G',
    name: '高大上',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529317923619&di=c7c1e8e86f028a98f5f1287f08185dda&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2017-12%2F15131353255776823.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'H',
    name: 'herbie',
    avatarUrl:
        'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=4174685487,4080018153&fm=11&gp=0.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'H',
    name: '何小冉',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529318082533&di=12e4f3d6b8bff6da451502fef002c1c1&imgtype=0&src=http%3A%2F%2Fpic.qqtn.com%2Fup%2F2018-6%2F2018060510054743138.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'J',
    name: '姬如雪',
    avatarUrl:
        'http://img5.duitang.com/uploads/item/201609/26/20160926124027_vxRkt.jpeg',
  ),
  FlutterWechatContact(seationKey: 'J', name: 'JC', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'J', name: 'JCZ', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'L', name: '联通', avatarUrl: ''),
  FlutterWechatContact(
    seationKey: 'L',
    name: '留学生',
    avatarUrl: 'http://www.qqzhi.com/uploadpic/2014-09-25/120539135.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'L',
    name: '李先森',
    avatarUrl: 'http://www.qqzhi.com/uploadpic/2015-01-16/110701410.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'L',
    name: '罗森',
    avatarUrl: 'http://www.qqzhi.com/uploadpic/2014-10-14/001343706.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'L',
    name: '老司机',
    avatarUrl:
        'http://img.bitscn.com/upimg/allimg/c160107/1452134O464060-32cR.jpg',
  ),
  FlutterWechatContact(seationKey: 'L', name: '辣眼睛', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'M', name: 'Mary', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'M', name: 'Master', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'P', name: '彭于晏', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'P', name: '彭简', avatarUrl: ''),
  FlutterWechatContact(
    seationKey: 'Q',
    name: '乔大',
    avatarUrl:
        'https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2957447029,2344598237&fm=27&gp=0.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'Q',
    name: '乔小',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529320656524&di=3840b5e429f92459c3a5211c904a74b8&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201406%2F29%2F20140629020408_ZtckA.jpeg',
  ),
  FlutterWechatContact(
    seationKey: 'Q',
    name: '邱小玲',
    avatarUrl:
        'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529320656523&di=afbc5ec78d4a4f28efd20585c0acbdaf&imgtype=0&src=http%3A%2F%2Fcdnq.duitang.com%2Fuploads%2Fitem%2F201502%2F22%2F20150222145005_BGBCX.jpeg',
  ),
  FlutterWechatContact(
    seationKey: 'Q',
    name: '齐东宇',
    avatarUrl:
        'https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1790389375,489698159&fm=27&gp=0.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'R',
    name: 'rogerMan',
    avatarUrl:
        'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=179495508,198350193&fm=27&gp=0.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'S',
    name: '石头熊',
    avatarUrl:
        'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1811676222,3366694286&fm=27&gp=0.jpg',
  ),
  FlutterWechatContact(seationKey: 'S', name: '孙丽', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'S', name: '沈家', avatarUrl: ''),
  FlutterWechatContact(
    seationKey: 'T',
    name: '天天',
    avatarUrl:
        'http://img.7139.com/file/201206/4f63c6678cefe6396e0c3d02e52dce47.jpg',
  ),
  FlutterWechatContact(
    seationKey: 'W',
    name: '薇薇安',
    avatarUrl:
        'http://image.bitauto.com/dealer/news/50001912/d140ad9a-5f2d-488d-aa09-7474cb8bc2d0.jpg',
  ),
  FlutterWechatContact(seationKey: 'X', name: '小猪', avatarUrl: ''),
  FlutterWechatContact(seationKey: 'X', name: '小猪佩奇', avatarUrl: ''),
  FlutterWechatContact(
    seationKey: 'X',
    name: '茜茜',
    avatarUrl:
        'http://dealer2.autoimg.cn/dealerdfs/g23/M10/C3/8E/620x0_1_q87_autohomedealer__wKgFV1hwh4eAY1azAABEQL7nzwY495.jpg',
  ),
  FlutterWechatContact(seationKey: 'Y', name: '杨洋', avatarUrl: ''),
  FlutterWechatContact(
    seationKey: 'Z',
    name: '张一山',
    avatarUrl:
        'http://img4.duitang.com/uploads/item/201510/08/20151008222232_rXEve.png',
  ),
  FlutterWechatContact(seationKey: '#', name: '%Dart', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '!Flutter', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '@android', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '#ios', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '&windows', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '*web', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '(java)', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '{JavaScript}', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '[ES6]', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '-kotlin', avatarUrl: ''),
  FlutterWechatContact(seationKey: '#', name: '=github', avatarUrl: ''),
];
