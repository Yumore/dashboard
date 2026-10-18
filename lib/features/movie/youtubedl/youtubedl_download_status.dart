/// Lifecycle of one download task.
///
/// `needsMuxer` replaces the source app's `muxing` state: this host has no
/// FFmpeg, so a split video+audio selection is surfaced instead of pretending
/// to merge it.
enum YoutubeDlDownloadStatus {
  pending('排队中'),
  running('下载中'),
  paused('已暂停'),
  done('已完成'),
  failed('下载失败'),
  cancelled('已取消'),
  needsMuxer('需要合成');

  const YoutubeDlDownloadStatus(this.label);

  final String label;

  bool get isTerminal =>
      this == done || this == failed || this == cancelled || this == needsMuxer;

  bool get isActive => this == pending || this == running || this == paused;
}
