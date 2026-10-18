import 'dart:convert';

import 'package:dashboard/features/short_video/douyin/douyin_downloaded_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 保存记录的持久化（宿主约定：shared_preferences）。
///
/// 源工程没有任何下载/保存逻辑，这里把“已保存到本地的视频”按作品 id 去重，
/// 最新一条排在最前，写入单个 JSON 数组键。
class DouyinDownloadStore {
  DouyinDownloadStore({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String storageKey = 'douyin_saved_videos';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<List<DouyinDownloadedVideo>> load() async {
    final raw = (await _prefs).getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <DouyinDownloadedVideo>[];
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <DouyinDownloadedVideo>[];
    }
    if (decoded is! List) {
      return const <DouyinDownloadedVideo>[];
    }
    final videos = <DouyinDownloadedVideo>[];
    for (final entry in decoded) {
      final video = DouyinDownloadedVideo.tryParse(entry);
      if (video != null) {
        videos.add(video);
      }
    }
    return videos;
  }

  Future<void> save(DouyinDownloadedVideo video) async {
    final videos = List<DouyinDownloadedVideo>.of(await load());
    videos.removeWhere((item) => item.awemeId == video.awemeId);
    videos.insert(0, video);
    await _write(videos);
  }

  Future<void> remove(String awemeId) async {
    final videos = List<DouyinDownloadedVideo>.of(await load());
    final before = videos.length;
    videos.removeWhere((item) => item.awemeId == awemeId);
    if (videos.length == before) {
      return;
    }
    await _write(videos);
  }

  Future<void> _write(List<DouyinDownloadedVideo> videos) async {
    await (await _prefs).setString(
      storageKey,
      jsonEncode(videos.map((video) => video.toJson()).toList(growable: false)),
    );
  }
}
