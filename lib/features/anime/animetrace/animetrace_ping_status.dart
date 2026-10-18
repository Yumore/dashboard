/// Reachability state of one source, produced by `AnimeTraceHealthProbe`.
///
/// The source app ran `dart_ping` here; the port measures a `dio` request
/// instead and keeps the same three states and the same `-1` time sentinel.
class AnimeTracePingStatus {
  const AnimeTracePingStatus({
    this.pinging = false,
    this.needPing = true,
    this.connectable = false,
    this.time = -1,
  });

  /// A probe is currently in flight.
  final bool pinging;

  /// Never probed yet.
  final bool needPing;

  /// Last probe answered with HTTP 200.
  final bool connectable;

  /// Round-trip time in milliseconds, `-1` when unknown.
  final int time;

  static const AnimeTracePingStatus unknown = AnimeTracePingStatus();

  factory AnimeTracePingStatus.pingingStatus() =>
      const AnimeTracePingStatus(pinging: true, needPing: false);

  AnimeTracePingStatus copyWith({
    bool? pinging,
    bool? needPing,
    bool? connectable,
    int? time,
  }) {
    return AnimeTracePingStatus(
      pinging: pinging ?? this.pinging,
      needPing: needPing ?? this.needPing,
      connectable: connectable ?? this.connectable,
      time: time ?? this.time,
    );
  }

  /// Source app labels: 测试中... / 未知 / `<n>ms` / 超时.
  String get label {
    if (pinging) return '测试中...';
    if (needPing) return '未知';
    if (connectable) return '${time}ms';
    return '超时';
  }

  @override
  String toString() =>
      'AnimeTracePingStatus(pinging=$pinging, connectable=$connectable, '
      'time=$time)';
}
