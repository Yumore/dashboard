import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_manifest.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_picker_dialog_state.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video.dart';
import 'package:flutter/material.dart';

/// Lets the user pick a single stream or a video+audio pair.
///
/// Tapping a muxed row downloads it directly. Long-pressing a video-only or
/// audio-only row records it as a merge candidate, exactly like the source
/// app's stream dialog.
class YoutubeDlStreamPickerDialog extends StatefulWidget {
  const YoutubeDlStreamPickerDialog({
    super.key,
    required this.video,
    required this.manifest,
  });

  final YoutubeDlVideo video;
  final YoutubeDlStreamManifest manifest;

  @override
  State<YoutubeDlStreamPickerDialog> createState() =>
      YoutubeDlStreamPickerDialogState();
}
