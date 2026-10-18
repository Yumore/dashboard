import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/app/config_helper.dart';
import 'package:dashboard/app/platform/app_file_writer.dart';
import 'package:dashboard/app/platform/app_platform.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/models/novel/novel_volume_item.dart';
import 'package:dashboard/models/version_info.dart';
import 'package:dashboard/protobuf/comic/detail_response.pb.dart';
import 'package:dashboard/protobuf/novel/novel_chapter_response.pb.dart';
import 'package:dashboard/views/comic/comic_author.dart';
import 'package:dashboard/views/comic/comic_category_detail.dart';
import 'package:dashboard/views/comic/comic_detail.dart';
import 'package:dashboard/views/comic/comic_special_detail.dart';
import 'package:dashboard/views/news/news_detail.dart';
import 'package:dashboard/views/novel/novel_category_detail.dart';
import 'package:dashboard/views/novel/novel_detail.dart';
import 'package:dashboard/views/other/comment_widget.dart';
import 'package:dashboard/views/other/web_page.dart';
import 'package:dashboard/views/reader/comic_reader.dart';
import 'package:dashboard/views/reader/novel_reader.dart';
import 'package:dashboard/views/user/my_comment_page.dart';
import 'package:dashboard/views/user/user_detail.dart';
import 'package:dashboard/views/user/user_history.dart';
import 'package:dashboard/views/user/user_subscribe.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photo_view/photo_view.dart';

class Utils {
  static EventBus changeComicHomeTabIndex = EventBus();
  static EventBus changeNovelHomeTabIndex = EventBus();
  static EventBus changHistory = EventBus();
  static EventBus changeHideBanner = EventBus();

  static void showSnackbarWithAction(
    BuildContext context,
    String content,
    String action,
    VoidCallback onTap,
  ) {
    final snackBar = SnackBar(
      content: Text(content),
      action: SnackBarAction(label: action, onPressed: onTap),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSnackbar(
    BuildContext context,
    String content, {
    Duration? duration,
  }) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: duration ?? const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static bool hideBanner = true;

  static Future<VersionInfo> checkVersion() async {
    try {
      var newVersion = await http.get(
        Uri.parse(
          "https://raw.staticdn.net/xiaoyaocz/dmzj_flutter/master/new_version.json?ts=" +
              DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
      var verInfo = VersionInfo.fromJson(
        jsonDecode(utf8.decode(newVersion.bodyBytes)),
      );
      hideBanner = verInfo.hide_banner;
      changeHideBanner.fire(hideBanner);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (int.parse(packageInfo.buildNumber) <
          int.parse(verInfo.version_code!)) {
        return verInfo;
      } else {
        return VersionInfo();
      }
    } catch (e) {
      return VersionInfo();
    }
  }

  static Future<bool> showAlertDialogAsync(
    BuildContext context,
    Widget title,
    Widget content,
  ) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
            child: const Text("确定"),
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("取消"),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return result;
  }

  static void showImageViewDialog(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (_) {
        return Stack(
          children: <Widget>[
            Material(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: PhotoView(
                    loadingBuilder: (context, event) {
                      return const Center(child: CircularProgressIndicator());
                    },
                    imageProvider: CachedNetworkImageProvider(
                      image,
                      headers: const {"Referer": "http://www.dmzj.com/"},
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: TextButton(
                onPressed: () async {
                  if (!AppPlatform.supportsFileSystem) {
                    AppToast.show(msg: '当前平台不支持保存到本地');
                    return;
                  }
                  try {
                    var file = DefaultCacheManager().getFileFromMemory(image);
                    var bytes = (await file)!.file.readAsBytesSync();
                    final path = await AppFileWriter.writeBytes(
                      bytes: bytes,
                      fileName:
                          '${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );
                    AppToast.show(
                      msg: path == null ? '当前平台不支持保存到本地' : '保存成功',
                    );
                  } catch (e) {
                    AppToast.show(msg: '保存失败');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("保存"),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget createCacheImage(
    String url,
    double width,
    double height, {
    BoxFit fit = BoxFit.fitWidth,
  }) {
    if (url.contains("dmzj1.com")) {
      url = url.replaceAll("dmzj1.com", "muwai.com");
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      httpHeaders: const {"Referer": "http://www.dmzj.com/"},
      placeholder: (context, url) => AspectRatio(
        aspectRatio: width / height,
        child: SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.photo, color: Colors.grey),
        ),
      ),
      errorWidget: (context, url, error) => AspectRatio(
        aspectRatio: width / height,
        child: SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      ),
    );
  }

  static CachedNetworkImageProvider createCachedImageProvider(String url) {
    if (url.contains("dmzj1.com")) {
      url = url.replaceAll("dmzj1.com", "muwai.com");
    }
    return CachedNetworkImageProvider(
      url,
      headers: const {"Referer": "http://www.dmzj.com/"},
    );
  }

  /// 打开页面
  /// [type] 1=漫画，2=小说，5=专题，6=网页，7=新闻，8=漫画作者，10=游戏，11=类目详情，12=个人中心
  static void openPage(
    BuildContext context,
    int id,
    int type, {
    String? url,
    String? title,
  }) {
    switch (type) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ComicDetailPage(id),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NovelDetailPage(id),
          ),
        );
        print("打开小说" + id.toString());
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ComicSpecialDetailPage(id),
          ),
        );
        print("打开专题" + id.toString());
        break;
      case 6:
        print("打开网页" + id.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WebViewPage(url!);
            },
          ),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NewsDetailPage(id, url!, title!);
            },
          ),
        );
        break;
      case 8:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ComicAuthorPage(id);
            },
          ),
        );
        break;
      case 10:
        print("打开游戏" + id.toString());
        break;
      case 11:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ComicCategoryDetailPage(id, title!);
            },
          ),
        );
        break;
      case 12:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return UserDetailPage(id);
            },
          ),
        );
        break;
      case 13:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NovelCategoryDetailPage(id, title!);
            },
          ),
        );
        break;
      default:
        break;
    }
  }

  static void openCommentPage(
    BuildContext context,
    int id,
    int type,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: CommentWidget(type, id),
        ),
      ),
    );
  }

  static void openSubscribePage(BuildContext context, {int index = 0}) {
    if (!ConfigHelper.getUserIsLogined()) {
      AppToast.show(msg: '没有登录');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => UserSubscribePage(index: index),
      ),
    );
  }

  static void openHistoryPage(BuildContext context) {
    if (!ConfigHelper.getUserIsLogined()) {
      AppToast.show(msg: '没有登录');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const UserHistoryPage(),
      ),
    );
  }

  static void openMyCommentPage(BuildContext context) {
    if (!ConfigHelper.getUserIsLogined()) {
      AppToast.show(msg: '没有登录');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const MyCommentPage(),
      ),
    );
  }

  static Future openComicReader(
    BuildContext context,
    int comicId,
    String comicTitle,
    bool isSubscribe,
    List<ComicDetailChapterInfoResponse> chapters,
    ComicDetailChapterInfoResponse item,
  ) async {
    var ls = chapters.toList();
    ls.sort((a, b) => a.chapterOrder.compareTo(b.chapterOrder));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            ComicReaderPage(comicId, comicTitle, ls, item, isSubscribe),
      ),
    );
  }

  static Future openNovelReader(
    BuildContext context,
    int novelId,
    List<NovelChapterVolumeResponse> chapters,
    NovelChapterItemResponse chapterItem, {
    String? novelTitle,
    bool isSubscribe = false,
  }) async {
    // var ls = chapters.toList();
    NovelVolumeChapterItem currentItem = NovelVolumeChapterItem(
      chapter_id: chapterItem.chapterId,
      chapter_name: chapterItem.chapterName,
      chapter_order: chapterItem.chapterOrder,
    );
    List<NovelVolumeChapterItem> items = [];

    for (var item in chapters) {
      for (var item2 in item.chapters) {
        if (item2.chapterId == currentItem.chapter_id) {
          currentItem.volume_id = item.volumeId;
          currentItem.volume_name = item.volumeName;
          items.add(currentItem);
        } else {
          var chapter = NovelVolumeChapterItem(
            chapter_id: item2.chapterId,
            chapter_name: item2.chapterName,
            chapter_order: item2.chapterOrder,
          );
          chapter.volume_id = item.volumeId;
          chapter.volume_name = item.volumeName;
          items.add(chapter);
        }
      }
    }
    // ls.sort((a, b) => a.chapter_order.compareTo(b.chapter_order));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => NovelReaderPage(
          novelId,
          novelTitle!,
          items,
          currentItem,
          subscribe: isSubscribe,
        ),
      ),
    );
  }
}
