import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/reading/eso/eso_audio_playback.dart';
import 'package:flutter/material.dart';

/// 音频/视频源与宿主播放器之间的桥（eso 自己维护 `AudioHandler`，
/// 宿主统一走 [MediaPlaybackPage]）。
class EsoPlaybackLauncher {
  const EsoPlaybackLauncher._();

  static Future<void> openAudio(
    BuildContext context, {
    required String title,
    required List<String> content,
  }) async {
    final sources = EsoAudioPlayback.sourcesFor(content, title);
    if (sources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有解析到可播放的地址')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(title: title, sources: sources),
      ),
    );
  }
}
