import 'flutterwechatfull_picture.dart';

/// One row of the 通讯录 tab, copied from `mock/contacts.json`.
class FlutterWechatFullContact {
  const FlutterWechatFullContact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.wechatId,
    required this.featureSign,
    required this.remarks,
    required this.gender,
    required this.tag,
    required this.pictures,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String wechatId;
  final String featureSign;
  final String remarks;

  /// `0` = male, `1` = female (source convention).
  final int gender;

  /// Pinyin initial used by the A-Z index (`A`-`Z`, else `#`).
  final String tag;

  final List<FlutterWechatFullPicture> pictures;

  bool get isFemale => gender == 1;

  /// The source shows the remark as nickname when it exists.
  String get nickname => remarks.isEmpty ? name : remarks;
}
