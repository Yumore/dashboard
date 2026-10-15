class ShortVideoClip {
  const ShortVideoClip({required this.poster, required this.video});

  final String poster;
  final String video;

  static const samples = [
    ShortVideoClip(
      poster: 'assets/short_video/images/v1.png',
      video: 'assets/short_video/videos/1.MP4',
    ),
    ShortVideoClip(
      poster: 'assets/short_video/images/v2.png',
      video: 'assets/short_video/videos/2.mp4',
    ),
  ];
}
