/// Watch status of a series, derived from a source's free-text play-status
/// label (for example "已完结", "连载中" or "第 03 集").
enum AnimeTracePlayStatus {
  unknown('未知'),
  notStarted('未开播'),
  playing('连载中'),
  finished('已完结');

  const AnimeTracePlayStatus(this.label);

  /// Human readable label shown in the series detail header.
  final String label;

  /// Maps a scraped status string onto a status value.
  ///
  /// The upstream app classifies by substring, in this exact order: a label
  /// containing "完结" wins over one containing "未", so "未完结" is `playing`
  /// and "已完结" is `finished`.
  static AnimeTracePlayStatus fromText(String text) {
    if (text.contains('完结')) return AnimeTracePlayStatus.finished;
    if (text.contains('未知')) return AnimeTracePlayStatus.unknown;
    if (text.contains('未')) return AnimeTracePlayStatus.notStarted;
    if (text.contains('第') || text.contains('连载')) {
      return AnimeTracePlayStatus.playing;
    }
    return AnimeTracePlayStatus.unknown;
  }
}
