import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';

/// 搜索结果 / 书架 / 阅读记录的统一模型
/// （移植 eso `lib/database/search_item.dart`，去掉 Hive 依赖）。
class EsoSearchItem {
  EsoSearchItem({
    this.searchUrl,
    this.chapterUrl,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.url,
    this.origin,
    this.originTag,
    this.ruleContentType,
    this.chaptersCount,
    this.reverseChapter,
    this.chapters,
    this.tags,
  }) {
    id = DateTime.now().microsecondsSinceEpoch;
    chapterListStyle = bigList;
    durChapter = '';
    durChapterIndex = 0;
    durContentIndex = 1;
    chapters = null;
    createTime ??= DateTime.now().microsecondsSinceEpoch;
    updateTime ??= DateTime.now().microsecondsSinceEpoch;
    lastReadTime ??= DateTime.now().microsecondsSinceEpoch;
  }

  /// 大列表目录样式（移植 `ChapterPageProvider.BigList`）。
  static const int bigList = 0;

  String? searchUrl;
  String? chapterUrl;

  int id = 0;

  /// 源名
  String? origin;

  /// 源 id
  String? originTag;

  /// 封面
  String? cover;

  /// 名称
  String? name;

  /// 作者
  String? author;

  /// 最新章节
  String? chapter;

  /// 简介
  String? description;

  /// 分类
  List<String>? tags;

  /// 搜索结果地址
  String? url;

  int? ruleContentType;
  int? chapterListStyle;
  String? durChapter;
  int? durChapterIndex;
  int? durContentIndex;
  int? chaptersCount;
  bool? reverseChapter;
  List<EsoChapterItem>? chapters;

  /// 收藏时间 / 更新时间 / 最后阅读时间
  int? createTime;
  int? updateTime;
  int? lastReadTime;

  bool get isNovel => ruleContentType == EsoApi.novel;

  @override
  bool operator ==(Object other) =>
      other is EsoSearchItem &&
      runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id;

  /// 与源实现一致：不落盘目录列表，`chapters` 始终为空，由打开时重新拉取。
  Map<String, dynamic> toJson() => <String, dynamic>{
        'searchUrl': searchUrl,
        'chapterUrl': chapterUrl,
        'id': id,
        'origin': origin,
        'originTag': originTag,
        'cover': cover,
        'name': name,
        'author': author,
        'chapter': chapter,
        'description': description,
        'url': url,
        'ruleContentType': ruleContentType,
        'chapterListStyle': chapterListStyle,
        'durChapter': durChapter,
        'durChapterIndex': durChapterIndex,
        'durContentIndex': durContentIndex,
        'chaptersCount': chaptersCount,
        'reverseChapter': reverseChapter,
        'tags': tags?.join(', '),
        'createTime': createTime,
        'updateTime': updateTime,
        'lastReadTime': lastReadTime,
      };

  EsoSearchItem.fromJson(Map<String, dynamic> json)
      : searchUrl = json['searchUrl'] as String?,
        chapterUrl = json['chapterUrl'] as String?,
        id = (json['id'] as num?)?.toInt() ?? 0,
        origin = json['origin'] as String?,
        originTag = json['originTag'] as String?,
        cover = json['cover'] as String?,
        name = json['name'] as String?,
        author = json['author'] as String?,
        chapter = json['chapter'] as String?,
        description = json['description'] as String?,
        url = json['url'] as String?,
        ruleContentType = (json['ruleContentType'] as num?)?.toInt(),
        chapterListStyle = (json['chapterListStyle'] as num?)?.toInt(),
        durChapter = json['durChapter'] as String?,
        durChapterIndex = (json['durChapterIndex'] as num?)?.toInt(),
        durContentIndex = (json['durContentIndex'] as num?)?.toInt(),
        chaptersCount = (json['chaptersCount'] as num?)?.toInt(),
        reverseChapter = json['reverseChapter'] as bool? ?? false,
        createTime = (json['createTime'] as num?)?.toInt() ??
            DateTime.now().microsecondsSinceEpoch,
        updateTime = (json['updateTime'] as num?)?.toInt() ??
            DateTime.now().microsecondsSinceEpoch,
        lastReadTime = (json['lastReadTime'] as num?)?.toInt() ??
            DateTime.now().microsecondsSinceEpoch,
        tags = (json['tags'] as String?)?.split(', ') ?? <String>[],
        chapters = <EsoChapterItem>[];

  /// 换源：保留 id 与阅读位置相关的重置规则（逐字移植）。
  void changeTo(EsoSearchItem searchItem) {
    searchUrl = searchItem.searchUrl;
    chapterUrl = searchItem.chapterUrl;
    origin = searchItem.origin;
    originTag = searchItem.originTag;
    cover = searchItem.cover;
    name = searchItem.name;
    author = searchItem.author;
    chapter = searchItem.chapter;
    description = searchItem.description;
    url = searchItem.url;
    tags = searchItem.tags;
    chapters = <EsoChapterItem>[];
    durChapter = '';
    durChapterIndex = 0;
    durContentIndex = 1;
  }

  /// 用本地信息补全搜索结果（仅非空字段覆盖）。
  void localAddInfo(EsoSearchItem searchItem) {
    if ((searchItem.author ?? '').isNotEmpty) author = searchItem.author;
    if ((searchItem.cover ?? '').isNotEmpty) cover = searchItem.cover;
    if (searchItem.tags?.isNotEmpty ?? false) tags = searchItem.tags;
    if ((searchItem.description ?? '').isNotEmpty) description = searchItem.description;
  }
}
