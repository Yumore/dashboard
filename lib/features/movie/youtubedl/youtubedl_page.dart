import 'package:dashboard/features/movie/youtubedl/youtubedl_download_queue.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_page_state.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_provider.dart';
import 'package:flutter/material.dart';

/// YouTube downloader: searches YouTube, picks extracted streams and queues
/// downloads. Stream extraction is injected through [YouTubeStreamProvider]
/// because the source app's `youtube_explode_dart` is not a host dependency.
class YoutubeDlPage extends StatefulWidget {
  const YoutubeDlPage({super.key, this.provider, this.queue});

  /// Injectable for tests; production uses the Dio-backed provider.
  final YouTubeStreamProvider? provider;

  /// Injectable for tests; when omitted the page owns a Dio-backed queue.
  final YoutubeDlDownloadQueue? queue;

  @override
  State<YoutubeDlPage> createState() => YoutubeDlPageState();
}
