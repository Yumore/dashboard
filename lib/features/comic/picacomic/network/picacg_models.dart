import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';

/// Joins a Picacg `thumb.fileServer` with a `thumb.path`.
///
/// Ports lib/network/picacg_network/methods.dart (`docs[i]["thumb"]
/// ["fileServer"] + "/static/" + docs[i]["thumb"]["path"]`).
String buildPicacgImageUrl(String fileServer, String path) =>
    '$fileServer/static/$path';

/// Category thumbnails use a trailing-slash tolerant join, exactly like
/// methods.dart's `getCategories` did before appending `/static/`.
String buildPicacgCategoryImageUrl(String fileServer, String path) =>
    fileServer.endsWith('/')
        ? '${fileServer}static/$path'
        : '$fileServer/static/$path';

/// Ports `Profile` from lib/network/picacg_network/models.dart.
class PicacgProfile {
  const PicacgProfile({
    required this.id,
    required this.avatarUrl,
    required this.email,
    required this.exp,
    required this.level,
    required this.name,
    required this.title,
    this.isPunched,
    this.slogan,
    this.frameUrl,
  });

  final String id;
  final String avatarUrl;
  final String email;
  final int exp;
  final int level;
  final String name;
  final String title;
  final bool? isPunched;
  final String? slogan;
  final String? frameUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'email': email,
        'name': name,
        'level': level,
        'exp': exp,
        'avatarUrl': avatarUrl,
        'frameUrl': frameUrl,
        'isPunched': isPunched,
        'slogan': slogan,
      };

  factory PicacgProfile.fromJson(Map<String, dynamic> json) => PicacgProfile(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        level: (json['level'] as num?)?.toInt() ?? 0,
        exp: (json['exp'] as num?)?.toInt() ?? 0,
        avatarUrl: json['avatarUrl']?.toString() ?? '',
        frameUrl: json['frameUrl']?.toString(),
        isPunched: json['isPunched'] as bool?,
        slogan: json['slogan']?.toString(),
      );

  /// Parses the raw `/users/profile` payload (`data.user`) exactly like
  /// methods.dart's `getProfile` did, including the avatar join rule.
  factory PicacgProfile.fromApiJson(Map<String, dynamic> json) {
    final avatar = json['avatar'];
    String avatarUrl;
    if (avatar is Map && avatar['fileServer'] != null && avatar['path'] != null) {
      avatarUrl =
          buildPicacgImageUrl(avatar['fileServer'].toString(), avatar['path'].toString());
    } else if (avatar is String) {
      avatarUrl = avatar;
    } else {
      avatarUrl = picacgDefaultAvatarUrl;
    }
    return PicacgProfile(
      id: json['_id']?.toString() ?? '',
      avatarUrl: avatarUrl,
      email: json['email']?.toString() ?? '',
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isPunched: json['isPunched'] as bool?,
      slogan: json['slogan']?.toString(),
      frameUrl: (json['character'] as String?) ?? (json['frame'] as String?),
    );
  }
}

/// Ports `defaultAvatarUrl` from methods.dart.
const String picacgDefaultAvatarUrl = 'DEFAULT AVATAR URL';

/// Ports `CategoryItem` from lib/network/picacg_network/models.dart.
class PicacgCategoryItem {
  const PicacgCategoryItem(this.title, this.path);

  final String title;
  final String path;
}

/// Ports `ComicItemBrief` from lib/network/picacg_network/models.dart.
class PicacgComicBrief extends BaseComic {
  const PicacgComicBrief(
    this.title,
    this.author,
    this.likes,
    this.path,
    this.id, {
    this.tags = const [],
    this.pages,
  });

  @override
  final String title;
  final String author;
  final int likes;
  final String path;
  @override
  final String id;
  @override
  final List<String> tags;
  final int? pages;

  @override
  String get cover => path;

  @override
  String get description => '$likes pages';

  @override
  String get subTitle => author;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'author': author,
        'likes': likes,
        'path': path,
        'id': id,
        'tags': tags,
        'pages': pages,
      };

  /// Parses one `data.comics.docs[i]` entry, tolerating a missing thumb,
  /// author, likesCount or pagesCount.
  factory PicacgComicBrief.fromApiJson(Map<String, dynamic> json) {
    final thumb = json['thumb'];
    final thumbMap = thumb is Map ? thumb : const <String, dynamic>{};
    final tags = <String>[];
    for (final tag in (json['tags'] as List?) ?? const []) {
      tags.add(tag.toString());
    }
    for (final category in (json['categories'] as List?) ?? const []) {
      tags.add(category.toString());
    }
    final fileServer = thumbMap['fileServer']?.toString() ?? '';
    final path = thumbMap['path']?.toString() ?? '';
    return PicacgComicBrief(
      json['title']?.toString() ?? 'Unknown',
      json['author']?.toString() ?? 'Unknown',
      ((json['likesCount'] ?? json['totalLikes']) as num?)?.toInt() ?? 0,
      (fileServer.isEmpty || path.isEmpty)
          ? ''
          : buildPicacgImageUrl(fileServer, path),
      json['_id']?.toString() ?? '',
      tags: tags,
      pages: (json['pagesCount'] as num?)?.toInt(),
    );
  }

  factory PicacgComicBrief.fromJson(Map<String, dynamic> json) =>
      PicacgComicBrief(
        json['title']?.toString() ?? '',
        json['author']?.toString() ?? '',
        (json['likes'] as num?)?.toInt() ?? 0,
        json['path']?.toString() ?? '',
        json['id']?.toString() ?? '',
        tags: <String>[
          for (final tag in (json['tags'] as List?) ?? const []) tag.toString(),
        ],
        pages: (json['pages'] as num?)?.toInt(),
      );
}

/// Ports `ComicItem` from lib/network/picacg_network/models.dart.
class PicacgComicItem with HistoryMixin {
  const PicacgComicItem({
    required this.creator,
    required this.title,
    required this.description,
    required this.thumbUrl,
    required this.author,
    required this.chineseTeam,
    required this.categories,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.isFavourite,
    required this.isLiked,
    required this.epsCount,
    required this.id,
    required this.pagesCount,
    required this.time,
    this.eps = const [],
    this.recommendation = const [],
  });

  final PicacgProfile creator;
  @override
  final String title;
  final String description;
  final String thumbUrl;
  final String author;
  final String chineseTeam;
  final List<String> categories;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isFavourite;
  final bool isLiked;
  final int epsCount;
  final String id;
  final int pagesCount;
  final String time;
  final List<String> eps;
  final List<PicacgComicBrief> recommendation;

  @override
  String get cover => thumbUrl;

  @override
  String get subTitle => author;

  @override
  HistoryType get historyType => HistoryType.picacg;

  @override
  String get target => id;

  @override
  int? get maxPage => pagesCount;

  PicacgComicBrief toBrief() =>
      PicacgComicBrief(title, author, likes, thumbUrl, id, pages: pagesCount);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'creator': creator.toJson(),
        'id': id,
        'title': title,
        'description': description,
        'thumbUrl': thumbUrl,
        'author': author,
        'chineseTeam': chineseTeam,
        'categories': categories,
        'tags': tags,
        'likes': likes,
        'comments': comments,
        'isLiked': isLiked,
        'isFavourite': isFavourite,
        'epsCount': epsCount,
        'time': time,
        'pagesCount': pagesCount,
      };

  factory PicacgComicItem.fromJson(Map<String, dynamic> json) =>
      PicacgComicItem(
        creator: PicacgProfile.fromJson(
            Map<String, dynamic>.from(json['creator'] as Map? ?? const {})),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        thumbUrl: json['thumbUrl']?.toString() ?? '',
        author: json['author']?.toString() ?? '',
        chineseTeam: json['chineseTeam']?.toString() ?? '',
        categories: <String>[
          for (final item in (json['categories'] as List?) ?? const [])
            item.toString(),
        ],
        tags: <String>[
          for (final item in (json['tags'] as List?) ?? const []) item.toString(),
        ],
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        comments: (json['comments'] as num?)?.toInt() ?? 0,
        isFavourite: json['isFavourite'] as bool? ?? false,
        isLiked: json['isLiked'] as bool? ?? false,
        epsCount: (json['epsCount'] as num?)?.toInt() ?? 0,
        id: json['id']?.toString() ?? '',
        pagesCount: (json['pagesCount'] as num?)?.toInt() ?? 0,
        time: json['time']?.toString() ?? '',
      );
}

/// Ports `Comment` from lib/network/picacg_network/models.dart.
class PicacgComment {
  const PicacgComment({
    required this.name,
    required this.avatarUrl,
    required this.userId,
    required this.level,
    required this.text,
    required this.reply,
    required this.id,
    required this.isLiked,
    required this.likes,
    this.frame,
    this.slogan,
    required this.time,
  });

  final String name;
  final String avatarUrl;
  final String userId;
  final int level;
  final String text;
  final int reply;
  final String id;
  final bool isLiked;
  final int likes;
  final String? frame;
  final String? slogan;
  final String time;

  @override
  String toString() => '$name:$text';

  factory PicacgComment.fromApiJson(Map<String, dynamic> json) {
    final user = json['_user'];
    final userMap = user is Map ? user : const <String, dynamic>{};
    final avatar = userMap['avatar'];
    final avatarMap = avatar is Map ? avatar : const <String, dynamic>{};
    final fileServer = avatarMap['fileServer']?.toString() ?? '';
    final path = avatarMap['path']?.toString() ?? '';
    return PicacgComment(
      name: userMap['name']?.toString() ?? '',
      avatarUrl: (fileServer.isEmpty || path.isEmpty)
          ? picacgDefaultAvatarUrl
          : buildPicacgImageUrl(fileServer, path),
      userId: userMap['_id']?.toString() ?? '',
      level: (userMap['level'] as num?)?.toInt() ?? 0,
      text: json['content']?.toString() ?? '',
      reply: (json['totalComments'] as num?)?.toInt() ?? 0,
      id: json['_id']?.toString() ?? '',
      isLiked: json['isLiked'] as bool? ?? false,
      likes: (json['likesCount'] as num?)?.toInt() ?? 0,
      frame: userMap['character']?.toString(),
      slogan: userMap['slogan']?.toString(),
      time: json['created_at']?.toString() ?? '',
    );
  }
}

/// Ports `Comments` from lib/network/picacg_network/models.dart.
class PicacgComments {
  const PicacgComments(this.comments, this.id, this.pages, this.loaded);

  final List<PicacgComment> comments;
  final String id;
  final int pages;
  final int loaded;
}
