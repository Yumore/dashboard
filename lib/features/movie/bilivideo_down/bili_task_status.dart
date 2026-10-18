/// Lifecycle of a persisted download task.
///
/// The source app only stored a single `downloadStatus` integer on completed
/// videos; this enum is the port's replacement, and [name] is what the store
/// writes into the `status` column so an upgrade never loses state.
enum BiliTaskStatus {
  /// Resolved, not started yet.
  pending,

  /// Range requests are in flight.
  downloading,

  /// Cancelled by the user but resumable from the bytes already on disk.
  paused,

  /// Every byte is on disk and the file is playable.
  completed,

  /// Failed; [BiliDownloadTask.errorMessage] explains why.
  failed;

  /// Whether the task is in its final state and cannot be resumed.
  bool get isTerminal => this == BiliTaskStatus.completed;

  /// Whether the task has bytes on disk that a resume can reuse.
  bool get isResumable =>
      this == BiliTaskStatus.paused ||
      this == BiliTaskStatus.downloading ||
      this == BiliTaskStatus.failed;

  String get label => switch (this) {
    BiliTaskStatus.pending => '等待中',
    BiliTaskStatus.downloading => '下载中',
    BiliTaskStatus.paused => '已暂停',
    BiliTaskStatus.completed => '已完成',
    BiliTaskStatus.failed => '失败',
  };

  /// Parses the persisted name, defaulting to [BiliTaskStatus.failed] for an
  /// unknown value rather than throwing on a corrupt row.
  static BiliTaskStatus fromName(String? name) =>
      BiliTaskStatus.values.firstWhere(
        (status) => status.name == name,
        orElse: () => BiliTaskStatus.failed,
      );
}
