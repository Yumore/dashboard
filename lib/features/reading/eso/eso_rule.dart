import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_api_type.dart';
import 'package:dashboard/features/reading/eso/eso_id.dart';
import 'package:dashboard/features/reading/eso/eso_rule_compress.dart';

/// eso 书源定义（移植 `lib/database/rule.dart` 的 `Rule`）。
///
/// 原作是 floor 数据库实体，宿主没有 `floor` 依赖，这里退化为纯数据类：
/// 持久化交给 [EsoRuleStore]，本类只保留字段、导入映射与 JSON 序列化。
class EsoRule {
  EsoRule({
    String? id,
    int? createTime,
    int? modifiedTime,
    this.enableUpload = true,
    this.author = '',
    this.postScript = '',
    this.name = '',
    this.host = '',
    this.icon = '',
    this.contentType = EsoApiType.manga,
    this.group = '',
    this.sort = 0,
    this.viewStyle = 0,
    this.useCryptoJS = false,
    this.loadJs = '',
    this.userAgent = '',
    this.loginUrl = '',
    this.cookies = '',
    this.enableDiscover = true,
    this.discoverUrl = '',
    this.discoverNextUrl = '',
    this.discoverItems = '',
    this.discoverList = '',
    this.discoverTags = '',
    this.discoverName = '',
    this.discoverCover = '',
    this.discoverAuthor = '',
    this.discoverChapter = '',
    this.discoverDescription = '',
    this.discoverResult = '',
    this.enableSearch = true,
    this.searchUrl = '',
    this.searchNextUrl = '',
    this.searchItems = '',
    this.searchList = '',
    this.searchTags = '',
    this.searchName = '',
    this.searchCover = '',
    this.searchAuthor = '',
    this.searchChapter = '',
    this.searchDescription = '',
    this.searchResult = '',
    this.enableMultiRoads = false,
    this.chapterUrl = '',
    this.chapterNextUrl = '',
    this.chapterRoads = '',
    this.chapterRoadName = '',
    this.chapterItems = '',
    this.chapterList = '',
    this.chapterName = '',
    this.chapterCover = '',
    this.chapterLock = '',
    this.chapterTime = '',
    this.chapterResult = '',
    this.contentUrl = '',
    this.contentNextUrl = '',
    this.contentItems = '',
  })  : id = id ?? EsoId.v4(),
        createTime = createTime ?? DateTime.now().microsecondsSinceEpoch,
        modifiedTime = modifiedTime ?? DateTime.now().microsecondsSinceEpoch;

  late String id;
  late int createTime;
  late int modifiedTime;
  late bool enableUpload;
  late String author;
  late String postScript;
  late String name;
  late String host;
  late String icon;
  late int contentType;
  late String group;
  late int sort;
  late int viewStyle;
  late bool useCryptoJS;
  late String loadJs;
  late String userAgent;

  late String loginUrl;
  late String cookies;

  late bool enableDiscover;
  late String discoverUrl;
  late String discoverNextUrl;
  late String discoverItems;
  late String discoverList;
  late String discoverTags;
  late String discoverName;
  late String discoverCover;
  late String discoverAuthor;
  late String discoverChapter;
  late String discoverDescription;
  late String discoverResult;

  late bool enableSearch;
  late String searchUrl;
  late String searchNextUrl;
  late String searchItems;
  late String searchList;
  late String searchTags;
  late String searchName;
  late String searchCover;
  late String searchAuthor;
  late String searchChapter;
  late String searchDescription;
  late String searchResult;

  late bool enableMultiRoads;
  late String chapterUrl;
  late String chapterNextUrl;
  late String chapterRoads;
  late String chapterRoadName;
  late String chapterItems;
  late String chapterList;
  late String chapterName;
  late String chapterCover;
  late String chapterLock;
  late String chapterTime;
  late String chapterResult;

  late String contentUrl;
  late String contentNextUrl;
  late String contentItems;

  String get ruleTypeName => EsoApiType.name(contentType);

  /// 新建书源的默认值（对应 `Rule.newRule()`）。
  factory EsoRule.newRule() => EsoRule(enableUpload: true);

  /// 复制为副本（对应 `Rule.replica()`）：新 id、名字加 `_copy`。
  EsoRule replica() {
    final copy = EsoRule.fromJson(toJson(true));
    copy.id = EsoId.v4();
    copy.name = '${name}_copy';
    return copy;
  }

  /// 从 map / JSON 字符串 / `eso://` 分享串导入。
  ///
  /// 支持 ZY-Player 源（`{"api": ..., "name": ...}`）与
  /// `discoverMoreKeys` 瀑布流改写。
  EsoRule.fromJson(dynamic jsonD, [EsoRule? rule]) {
    Map<String, dynamic>? json;
    if (jsonD is Map) {
      json = Map<String, dynamic>.from(jsonD);
    } else if (jsonD is String) {
      if (jsonD.startsWith('eso')) {
        json = _decodeMap(EsoRuleCompress.decompressString(jsonD));
      } else if (jsonD.startsWith('{')) {
        json = _decodeMap(jsonD);
      }
    }
    if (json == null || json.isEmpty) {
      id = EsoId.v4();
      createTime = DateTime.now().microsecondsSinceEpoch;
      modifiedTime = DateTime.now().microsecondsSinceEpoch;
      enableUpload = true;
      author = '';
      postScript = '';
      name = '';
      host = '';
      icon = '';
      contentType = EsoApiType.manga;
      group = '';
      sort = 0;
      viewStyle = 0;
      useCryptoJS = false;
      loadJs = '';
      userAgent = '';
      loginUrl = '';
      cookies = '';
      enableDiscover = true;
      discoverUrl = '';
      discoverNextUrl = '';
      discoverItems = '';
      discoverList = '';
      discoverTags = '';
      discoverName = '';
      discoverCover = '';
      discoverAuthor = '';
      discoverChapter = '';
      discoverDescription = '';
      discoverResult = '';
      enableSearch = true;
      searchUrl = '';
      searchNextUrl = '';
      searchItems = '';
      searchList = '';
      searchTags = '';
      searchName = '';
      searchCover = '';
      searchAuthor = '';
      searchChapter = '';
      searchDescription = '';
      searchResult = '';
      enableMultiRoads = false;
      chapterUrl = '';
      chapterNextUrl = '';
      chapterRoads = '';
      chapterRoadName = '';
      chapterItems = '';
      chapterList = '';
      chapterName = '';
      chapterCover = '';
      chapterLock = '';
      chapterTime = '';
      chapterResult = '';
      contentUrl = '';
      contentNextUrl = '';
      contentItems = '';
      return;
    }
    final defaultRule = rule ?? EsoRule.newRule();
    if (json['api'] != null && json['name'] != null) {
      json = zyPlayerJson(json['key'], json['name'], json['api']);
    }

    var discoverUrl2 = '${json['discoverUrl'] ?? defaultRule.discoverUrl}';
    var group2 = json['group'] ?? defaultRule.group;
    if (json['discoverMoreKeys'] != null) {
      group2 = 'discoverMoreKeys;$group2';
      final more = '${json['discoverMoreKeys']}';
      if (more.contains('"isWrap": true') || more.contains('"isWrap":true')) {
        discoverUrl2 = '''测试新发现瀑布流$discoverUrl2;
;
@@DiscoverRule:${more.replaceFirst('"list"', '"rules"').replaceAll('"title"', '"option"').replaceAll('"requestFilters"', '"options"')}
        ''';
      } else {
        discoverUrl2 = """@js:
var discoverMoreKeys = $more;
;;
var r = [];
var tabIndex = 0;
var pageIndex = page;
for(var list of discoverMoreKeys.list){
  var filter = list.requestFilters[0];
  for(var item of filter.items){
    var params = {
      tabIndex,
      pageIndex,
      filters: {tabIndex, pageIndex, [filter.key]: item.value}
    };
    var url = ${discoverUrl2.replaceFirst("@js:", "")};

    r.push(`\${list.title}::\${item.title}::\${typeof(url) == 'string' ? url : JSON.stringify(url)}`)
  }
  tabIndex++;
}
r;
""";
      }
    }

    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    enableUpload = json['upload'] ?? defaultRule.enableUpload;
    author = json['author'] ?? defaultRule.author;
    postScript = json['postScript'] ?? defaultRule.postScript;
    name = json['name'] ?? defaultRule.name;
    host = json['host'] ?? defaultRule.host;
    icon = json['icon'] ?? defaultRule.icon;
    group = group2;
    contentType = json['contentType'] ?? defaultRule.contentType;
    sort = json['sort'] ?? defaultRule.sort;
    viewStyle = json['viewStyle'] ?? 0;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['userAgent'] ?? json['httpHeaders'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = discoverUrl2;
    discoverNextUrl = json['discoverNextUrl'] ?? defaultRule.discoverNextUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList = json['discoverList'] ?? defaultRule.discoverList;
    discoverTags = json['discoverTags'] ?? defaultRule.discoverTags;
    discoverName = json['discoverName'] ?? defaultRule.discoverName;
    discoverCover = json['discoverCover'] ?? defaultRule.discoverCover;
    discoverAuthor = json['discoverAuthor'] ?? defaultRule.discoverAuthor;
    discoverChapter = json['discoverChapter'] ?? defaultRule.discoverChapter;
    discoverDescription =
        json['discoverDescription'] ?? defaultRule.discoverDescription;
    discoverResult = json['discoverResult'] ?? defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['searchUrl'] ?? defaultRule.searchUrl;
    searchNextUrl = json['searchNextUrl'] ?? defaultRule.searchNextUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['searchList'] ?? defaultRule.searchList;
    searchTags = json['searchTags'] ?? defaultRule.searchTags;
    searchName = json['searchName'] ?? defaultRule.searchName;
    searchCover = json['searchCover'] ?? defaultRule.searchCover;
    searchAuthor = json['searchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['searchChapter'] ?? defaultRule.searchChapter;
    searchDescription =
        json['searchDescription'] ?? defaultRule.searchDescription;
    searchResult = json['searchResult'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['chapterUrl'] ?? defaultRule.chapterUrl;
    chapterNextUrl = json['chapterNextUrl'] ?? defaultRule.chapterNextUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterList = json['chapterList'] ?? defaultRule.chapterList;
    chapterName = json['chapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['chapterResult'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentNextUrl = json['contentNextUrl'] ?? defaultRule.contentNextUrl;
    contentItems = json['contentItems'] ?? defaultRule.contentItems;
    loginUrl = json['loginUrl'] ?? defaultRule.loginUrl;
    cookies = json['cookies'] ?? defaultRule.cookies;
  }

  /// 异次元漫画源导入（移植 `Rule.fromYiCiYuan`）。
  ///
  /// 只转换以 `tag` / `class` / `id` 开头的选择器，并把单符号转成 eso 语法。
  EsoRule.fromYiCiYuan(Map<String, dynamic> json, [EsoRule? rule]) {
    final defaultRule = rule ?? EsoRule.newRule();
    for (final key in json.keys.toList()) {
      var s = '${json[key]}';
      if (s.startsWith('\$') ||
          s.startsWith('http') ||
          s.startsWith(':') ||
          s.startsWith('@') ||
          s.startsWith('/')) {
        continue;
      }
      final flag = s.startsWith('-');
      if (flag) {
        s = s.substring(1);
      }
      if (s.startsWith('tag') || s.startsWith('class') || s.startsWith('id')) {
        s = s
            .replaceAll(RegExp(r'(?<!\|)\|(?!\|)'), '||')
            .replaceAll(RegExp(r'(?<!&)&(?!&)'), '&&')
            .replaceAll(RegExp(r'(?<!#)#(?!#)'), '##')
            .replaceAll('@tag.', ' ')
            .replaceAll('@class.', ' .')
            .replaceAll('@id.', ' #')
            .replaceAll('@children', '>*')
            .replaceAll('tag.', '')
            .replaceAll('class.', '.')
            .replaceAll('id.', '#');
        json[key] = (flag ? '-' : '') + s.trim();
      }
    }

    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    enableUpload = json['upload'] ?? defaultRule.enableUpload;
    author = json['author'] ?? defaultRule.author;
    postScript = json['sourceRemark'] ?? defaultRule.postScript;
    group = json['bookSourceGroup'] ?? defaultRule.group;
    name = json['bookSourceName'] ?? defaultRule.name;
    host = json['bookSourceUrl'] ?? defaultRule.host;
    icon = json['icon'] ?? defaultRule.icon;
    // 原作这里的三元优先级有坑：`a ?? b == c ? d : e` 会解析成
    // `(a ?? (b == c)) ? d : e`，即只要 contentType 非 0/非空就变成「图片」。
    // 迁移时保留该行为，便于与分享串互相导入。
    contentType = json['contentType'] ?? json['bookSourceType'] == 'CARTOON'
        ? EsoApiType.manga
        : json['bookSourceType'] == ''
            ? EsoApiType.novel
            : defaultRule.contentType;
    sort = json['serialNumber'] ?? defaultRule.sort;
    viewStyle = 0;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['httpUserAgent'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = json['ruleFindUrl'] ?? defaultRule.discoverUrl;
    discoverNextUrl = json['discoverNextUrl'] ?? defaultRule.discoverNextUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList =
        json['ruleFindList'] ?? json['ruleSearchList'] ?? defaultRule.discoverList;
    discoverTags =
        json['ruleFindKind'] ?? json['ruleSearchKind'] ?? defaultRule.discoverTags;
    discoverName =
        json['ruleFindName'] ?? json['ruleSearchName'] ?? defaultRule.discoverName;
    discoverCover = json['ruleFindCoverUrl'] ??
        json['ruleSearchCoverUrl'] ??
        defaultRule.discoverCover;
    discoverAuthor = json['ruleFindAuthor'] ??
        json['ruleSearchAuthor'] ??
        defaultRule.discoverAuthor;
    discoverChapter = json['ruleFindLastChapter'] ??
        json['ruleSearchLastChapter'] ??
        defaultRule.discoverChapter;
    discoverDescription = json['ruleFindIntroduce'] ??
        json['ruleSearchIntroduce'] ??
        defaultRule.discoverDescription;
    discoverResult = json['ruleFindNoteUrl'] ??
        json['ruleSearchNoteUrl'] ??
        defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['ruleSearchUrl'] ?? defaultRule.searchUrl;
    searchNextUrl = json['searchNextUrl'] ?? defaultRule.searchNextUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['ruleSearchList'] ?? defaultRule.searchList;
    searchTags = json['ruleSearchKind'] ?? defaultRule.searchTags;
    searchName = json['ruleSearchName'] ?? defaultRule.searchName;
    searchCover = json['ruleSearchCoverUrl'] ?? defaultRule.searchCover;
    searchAuthor = json['ruleSearchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['ruleSearchLastChapter'] ?? defaultRule.searchChapter;
    searchDescription =
        json['ruleSearchIntroduce'] ?? defaultRule.searchDescription;
    searchResult = json['ruleSearchNoteUrl'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['ruleChapterUrl'] ?? defaultRule.chapterUrl;
    chapterNextUrl = json['chapterNextUrl'] ?? defaultRule.chapterNextUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterList = json['ruleChapterList'] ?? defaultRule.chapterList;
    chapterName = json['ruleChapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['ruleContentUrl'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentNextUrl = json['contentNextUrl'] ?? defaultRule.contentNextUrl;
    contentItems = json['ruleBookContent'] ?? defaultRule.contentItems;
    loginUrl = json['loginUrl'] ?? defaultRule.loginUrl;
    cookies = json['cookies'] ?? defaultRule.cookies;
  }

  Map<String, dynamic> toJson([bool withCookies = false]) => <String, dynamic>{
        'id': id,
        'createTime': createTime,
        'modifiedTime': modifiedTime,
        'enableUpload': enableUpload,
        'author': author,
        'postScript': postScript,
        'name': name,
        'host': host,
        'icon': icon,
        'group': group,
        'contentType': contentType,
        'sort': sort,
        'useCryptoJS': useCryptoJS,
        'loadJs': loadJs,
        'userAgent': userAgent,
        'enableDiscover': enableDiscover,
        'discoverUrl': discoverUrl,
        'discoverNextUrl': discoverNextUrl,
        'discoverItems': discoverItems,
        'discoverList': discoverList,
        'discoverTags': discoverTags,
        'discoverName': discoverName,
        'discoverCover': discoverCover,
        'discoverAuthor': discoverAuthor,
        'discoverChapter': discoverChapter,
        'discoverDescription': discoverDescription,
        'discoverResult': discoverResult,
        'enableSearch': enableSearch,
        'searchUrl': searchUrl,
        'searchNextUrl': searchNextUrl,
        'searchItems': searchItems,
        'searchList': searchList,
        'searchTags': searchTags,
        'searchName': searchName,
        'searchCover': searchCover,
        'searchAuthor': searchAuthor,
        'searchChapter': searchChapter,
        'searchDescription': searchDescription,
        'searchResult': searchResult,
        'enableMultiRoads': enableMultiRoads,
        'chapterRoads': chapterRoads,
        'chapterRoadName': chapterRoadName,
        'chapterUrl': chapterUrl,
        'chapterNextUrl': chapterNextUrl,
        'chapterItems': chapterItems,
        'chapterList': chapterList,
        'chapterName': chapterName,
        'chapterCover': chapterCover,
        'chapterLock': chapterLock,
        'chapterTime': chapterTime,
        'chapterResult': chapterResult,
        'contentUrl': contentUrl,
        'contentNextUrl': contentNextUrl,
        'contentItems': contentItems,
        'loginUrl': loginUrl,
        'cookies': withCookies == true ? cookies : '',
        'viewStyle': viewStyle,
      }..removeWhere((key, value) => value == null || value == '');

  /// ZY-Player 视频源转换（移植 `Rule.jsonZYPlayer`）。
  static Map<String, dynamic> zyPlayerJson(dynamic key, dynamic name, dynamic api) =>
      <String, dynamic>{
        'id': key?.toString() ?? EsoId.v4(),
        'createTime': DateTime.now().microsecondsSinceEpoch,
        'modifiedTime': DateTime.now().microsecondsSinceEpoch,
        'enableUpload': true,
        'author': 'ZY-Player',
        'postScript': 'https://github.com/cuiocean/ZY-Player',
        'name': name?.toString() ?? '麻花',
        'host': api?.toString() ?? '',
        'icon': '',
        'group': 'ZY-Player',
        'contentType': 2,
        'sort': 0,
        'useCryptoJS': false,
        'loadJs': '',
        'userAgent': '',
        'enableDiscover': true,
        'discoverUrl':
            "@js:\r\n(async () => {\r\n  var html = await http('');\r\n  var id = await xpath(html, '//class/*/@id');\r\n  var name = await xpath(html, '//class/*/text()');\r\n  var list = [\"全部::?ac=videolist&pg=\$page\"]\r\n  for (var i = 0; i < id.length; i++) {\r\n    list.push(`分类::\${name[i]}::?ac=videolist&t=\${id[i]}&pg=\$page`)\r\n  }\r\n  return list;\r\n})();",
        'discoverNextUrl': '',
        'discoverItems': '',
        'discoverList': '//video',
        'discoverTags': '//type/text()',
        'discoverName': '//name##.*\\[|\\].*',
        'discoverCover': '//pic/text()',
        'discoverAuthor': '演员:{{//actor##.*\\[|\\].*}},导演:{{//director##.*\\[|\\].*}}',
        'discoverChapter': '//last/text()',
        'discoverDescription': '//des##.*\\[|\\].*',
        'discoverResult': '//id/text()',
        'enableSearch': true,
        'searchUrl': '?wd=\$keyword&pg=\$page',
        'searchNextUrl': '',
        'searchItems': '',
        'searchList': '//video',
        'searchTags': '//type/text()',
        'searchName': '//name##.*\\[|\\].*',
        'searchCover': '//pic/text()',
        'searchAuthor': '演员:{{//actor##.*\\[|\\].*}},导演:{{//director##.*\\[|\\].*}}',
        'searchChapter': '//last/text()',
        'searchDescription': '//des##.*\\[|\\].*',
        'searchResult': '//id/text()',
        'enableMultiRoads': true,
        'chapterRoads': '//dd',
        'chapterRoadName': '@js:result.match(/flag="(.*?)"/)[1]',
        'chapterUrl': '?ac=videolist&ids=\$result',
        'chapterNextUrl': '',
        'chapterItems': '',
        'chapterList': '@js:result.replace(/.*\\[|\\].*/g,"").split("#")',
        'chapterName': '@js:result.split("\$")[0]',
        'chapterCover': '',
        'chapterLock': '',
        'chapterTime': '',
        'chapterResult': '@js:result.split("\$")[1]||result.split("\$")[0]',
        'contentUrl': 'null',
        'contentNextUrl': '',
        'contentItems': '@js:lastResult',
        'loginUrl': '',
        'cookies': '',
        'viewStyle': 0,
      };

  /// 批量备份为 JSON 字符串（对应 `Rule.backupRules`）。
  static String backup(List<EsoRule> rules) =>
      json.encode(rules.map((e) => e.toJson()).toList());

  /// 从备份 JSON 还原书源列表（对应 `Rule.restore`）。
  static List<EsoRule> restore(dynamic data) {
    final rules = <EsoRule>[];
    if (data is List) {
      for (final item in data) {
        rules.add(EsoRule.fromJson(item));
      }
    }
    return rules;
  }

  static Map<String, dynamic>? _decodeMap(String text) {
    final decoded = jsonDecode(text);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

}
