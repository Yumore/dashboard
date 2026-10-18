/// The kind of track a stream carries.
enum YoutubeDlStreamType {
  audio('音频'),
  video('视频');

  const YoutubeDlStreamType(this.label);

  final String label;
}
