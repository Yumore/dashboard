/// Mirrors the source app's stream filter tabs.
enum YoutubeDlStreamFilter {
  all('全部'),
  videoAudio('视频 + 音频'),
  videoOnly('仅视频'),
  audioOnly('仅音频');

  const YoutubeDlStreamFilter(this.label);

  final String label;
}
