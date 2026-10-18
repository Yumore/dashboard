import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';

/// Port of the source `flutter_tiktok/lib/mock/video.dart` sample entries.
///
/// The source has no API client: it hard-codes nine remote sample file names and
/// builds `https://static.ybhospital.net/<name>` URLs for them.
class FlutterTiktokSampleVideo {
  const FlutterTiktokSampleVideo({
    required this.url,
    required this.image,
    required this.desc,
  });

  final String url;
  final String image;
  final String? desc;

  /// Same order as `videoList` in the source mock file.
  static const List<String> fileNames = <String>[
    'test-video-10.MP4',
    'test-video-6.mp4',
    'test-video-9.MP4',
    'test-video-8.MP4',
    'test-video-7.MP4',
    'test-video-1.mp4',
    'test-video-2.mp4',
    'test-video-3.mp4',
    'test-video-4.mp4',
  ];

  static List<FlutterTiktokSampleVideo> fetchVideo() {
    return <FlutterTiktokSampleVideo>[
      for (final String name in fileNames)
        FlutterTiktokSampleVideo(
          image: '',
          url: '${FlutterTiktokDemoConfig.sampleHost}$name',
          desc: name,
        ),
    ];
  }

  @override
  String toString() => 'image:$image\nvideo:$url';
}
