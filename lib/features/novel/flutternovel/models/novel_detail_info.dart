import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_rating.dart';
import 'package:dashboard/features/novel/flutternovel/models/star_rating.dart';

/// Ported from `NovelDetailInfo` in entity_novel_detail.dart — the
/// `book/{id}` detail payload. Every `@JsonKey` from the source is preserved;
/// only the parsing is hand-written and null-tolerant.
class NovelDetailInfo {
  NovelDetailInfo({
    this.id,
    this.title,
    this.author,
    this.majorCate,
    this.cover,
    this.longIntro,
    this.starRatingCount,
    this.starRatings = const <StarRating>[],
    this.isMakeMoneyLimit,
    this.contentLevel,
    this.isFineBook,
    this.safelevel,
    this.allowFree,
    this.originalAuthor,
    this.anchors = const <dynamic>[],
    this.authorDesc,
    this.rating,
    this.hasCopyright,
    this.buytype,
    this.sizetype,
    this.superscript,
    this.currency,
    this.contentType,
    this.le,
    this.allowMonthly,
    this.allowVoucher,
    this.allowBeanVoucher,
    this.hasCp,
    this.banned,
    this.postCount,
    this.totalFollower,
    this.latelyFollower,
    this.followerCount,
    this.wordCount,
    this.serializeWordCount,
    this.retentionRatio,
    this.updated,
    this.isSerial,
    this.chaptersCount,
    this.lastChapter,
    this.gender = const <dynamic>[],
    this.tags = const <dynamic>[],
    this.advertRead,
    this.donate,
    this.copyright,
    this.gg,
    this.isForbidForFreeApp,
    this.isAllowNetSearch,
    this.limit,
    this.copyrightInfo,
    this.copyrightDesc,
  });

  String? id;
  String? title;
  String? author;
  String? majorCate;
  String? cover;
  String? longIntro;
  int? starRatingCount;
  List<StarRating> starRatings;
  bool? isMakeMoneyLimit;
  int? contentLevel;
  bool? isFineBook;
  int? safelevel;
  bool? allowFree;
  String? originalAuthor;
  List<dynamic> anchors;
  String? authorDesc;
  NovelRating? rating;
  bool? hasCopyright;
  int? buytype;
  int? sizetype;
  String? superscript;
  int? currency;
  String? contentType;
  bool? le;
  bool? allowMonthly;
  bool? allowVoucher;
  bool? allowBeanVoucher;
  bool? hasCp;
  int? banned;
  int? postCount;
  int? totalFollower;
  int? latelyFollower;
  int? followerCount;
  int? wordCount;
  int? serializeWordCount;
  String? retentionRatio;
  String? updated;
  bool? isSerial;
  int? chaptersCount;
  String? lastChapter;
  List<dynamic> gender;
  List<dynamic> tags;
  bool? advertRead;
  bool? donate;
  String? copyright;
  bool? gg;
  bool? isForbidForFreeApp;
  bool? isAllowNetSearch;
  bool? limit;
  String? copyrightInfo;
  String? copyrightDesc;

  factory NovelDetailInfo.fromJson(Map<String, dynamic> json) =>
      NovelDetailInfo(
        id: readString(json, '_id'),
        title: readString(json, 'title'),
        author: readString(json, 'author'),
        majorCate: readString(json, 'majorCate'),
        cover: readString(json, 'cover'),
        longIntro: readString(json, 'longIntro'),
        starRatingCount: readInt(json, 'starRatingCount'),
        starRatings: readMapList(
          json,
          'starRatings',
        ).map(StarRating.fromJson).toList(),
        isMakeMoneyLimit: readBool(json, 'isMakeMoneyLimit'),
        contentLevel: readInt(json, 'contentLevel'),
        isFineBook: readBool(json, 'isFineBook'),
        safelevel: readInt(json, 'safelevel'),
        allowFree: readBool(json, 'allowFree'),
        originalAuthor: readString(json, 'originalAuthor'),
        anchors: readList(json, 'anchors'),
        authorDesc: readString(json, 'authorDesc'),
        rating: json['rating'] is Map
            ? NovelRating.fromJson(
                (json['rating'] as Map).cast<String, dynamic>(),
              )
            : null,
        hasCopyright: readBool(json, 'hasCopyright'),
        buytype: readInt(json, 'buytype'),
        sizetype: readInt(json, 'sizetype'),
        superscript: readString(json, 'superscript'),
        currency: readInt(json, 'currency'),
        contentType: readString(json, 'contentType'),
        le: readBool(json, '_le'),
        allowMonthly: readBool(json, 'allowMonthly'),
        allowVoucher: readBool(json, 'allowVoucher'),
        allowBeanVoucher: readBool(json, 'allowBeanVoucher'),
        hasCp: readBool(json, 'hasCp'),
        banned: readInt(json, 'banned'),
        postCount: readInt(json, 'postCount'),
        totalFollower: readInt(json, 'totalFollower'),
        latelyFollower: readInt(json, 'latelyFollower'),
        followerCount: readInt(json, 'followerCount'),
        wordCount: readInt(json, 'wordCount'),
        serializeWordCount: readInt(json, 'serializeWordCount'),
        retentionRatio: readString(json, 'retentionRatio'),
        updated: readString(json, 'updated'),
        isSerial: readBool(json, 'isSerial'),
        chaptersCount: readInt(json, 'chaptersCount'),
        lastChapter: readString(json, 'lastChapter'),
        gender: readList(json, 'gender'),
        tags: readList(json, 'tags'),
        advertRead: readBool(json, 'advertRead'),
        donate: readBool(json, 'donate'),
        copyright: readString(json, 'copyright'),
        gg: readBool(json, '_gg'),
        isForbidForFreeApp: readBool(json, 'isForbidForFreeApp'),
        isAllowNetSearch: readBool(json, 'isAllowNetSearch'),
        limit: readBool(json, 'limit'),
        copyrightInfo: readString(json, 'copyrightInfo'),
        copyrightDesc: readString(json, 'copyrightDesc'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'title': title,
    'author': author,
    'majorCate': majorCate,
    'cover': cover,
    'longIntro': longIntro,
    'starRatingCount': starRatingCount,
    'starRatings': starRatings.map((rating) => rating.toJson()).toList(),
    'isMakeMoneyLimit': isMakeMoneyLimit,
    'contentLevel': contentLevel,
    'isFineBook': isFineBook,
    'safelevel': safelevel,
    'allowFree': allowFree,
    'originalAuthor': originalAuthor,
    'anchors': anchors,
    'authorDesc': authorDesc,
    'rating': rating?.toJson(),
    'hasCopyright': hasCopyright,
    'buytype': buytype,
    'sizetype': sizetype,
    'superscript': superscript,
    'currency': currency,
    'contentType': contentType,
    '_le': le,
    'allowMonthly': allowMonthly,
    'allowVoucher': allowVoucher,
    'allowBeanVoucher': allowBeanVoucher,
    'hasCp': hasCp,
    'banned': banned,
    'postCount': postCount,
    'totalFollower': totalFollower,
    'latelyFollower': latelyFollower,
    'followerCount': followerCount,
    'wordCount': wordCount,
    'serializeWordCount': serializeWordCount,
    'retentionRatio': retentionRatio,
    'updated': updated,
    'isSerial': isSerial,
    'chaptersCount': chaptersCount,
    'lastChapter': lastChapter,
    'gender': gender,
    'tags': tags,
    'advertRead': advertRead,
    'donate': donate,
    'copyright': copyright,
    '_gg': gg,
    'isForbidForFreeApp': isForbidForFreeApp,
    'isAllowNetSearch': isAllowNetSearch,
    'limit': limit,
    'copyrightInfo': copyrightInfo,
    'copyrightDesc': copyrightDesc,
  };
}
