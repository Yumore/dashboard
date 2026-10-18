import 'package:dashboard/features/movie/bilivideo_down/bili_download_controller.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_down_page_state.dart';
import 'package:flutter/material.dart';

/// bilibili video downloader: paste a link, resolve the stream, download it with
/// the multi-threaded range downloader and play the result locally.
///
/// The controller is injectable so the page can be driven by tests or embedded
/// in another screen; when [controller] is omitted the page owns a controller
/// built from its own Dio instances, [cookie] and [storageDirectory].
class BiliVideoDownPage extends StatefulWidget {
  const BiliVideoDownPage({
    this.controller,
    this.cookie,
    this.storageDirectory,
    this.now,
    super.key,
  });

  /// Pre-built controller; when `null` the state creates and disposes its own.
  final BiliDownloadController? controller;

  /// The user's own bilibili cookie for member-only streams (optional).
  final String? cookie;

  /// Overrides the download directory; defaults to
  /// [BiliDownloadController.defaultStorageDirectory].
  final Future<String> Function()? storageDirectory;

  /// Overrides the clock, for tests.
  final DateTime Function()? now;

  @override
  State<BiliVideoDownPage> createState() => BiliVideoDownPageState();
}
