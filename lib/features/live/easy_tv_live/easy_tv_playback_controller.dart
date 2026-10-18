import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel.dart';

/// Outcome of a failed playback attempt, mirroring the source app's line
/// failover: try the next URL, or keep the last line and show the error.
enum EasyTvLineFailure { switched, exhausted }

/// Source-selection and channel-navigation state for the easy_tv_live player.
///
/// This is the pure business logic of the source app's `LiveHomePageState`:
/// global serial numbers for channel up/down (no wrap), a per-channel line
/// index that advances modulo line count for manual switching, and failover to
/// the next line while clamping at the last one.
class EasyTvPlaybackController {
  EasyTvPlaybackController({required EasyTvCatalog catalog, int? serialNum})
    : _catalog = catalog {
    final fallback = catalog.channels.isEmpty
        ? 0
        : catalog.channels.first.serialNum;
    openSerial(serialNum ?? fallback);
  }

  EasyTvCatalog _catalog;
  EasyTvChannel? _channel;
  int _lineIndex = 0;

  EasyTvCatalog get catalog => _catalog;

  EasyTvChannel? get channel => _channel;

  int get serialNum => _channel?.serialNum ?? 0;

  int get lineIndex => _lineIndex;

  List<Uri> get urls => _channel?.urls ?? const <Uri>[];

  int get lineCount => urls.length;

  String get lineLabel => '线路 ${_lineIndex + 1}';

  /// `User-Agent` requested by the playlist's `#UA-Hint`/`ua` parameter.
  Map<String, String> get requestHeaders {
    final hint = _catalog.uaHint.trim();
    return hint.isEmpty
        ? const <String, String>{}
        : <String, String>{'User-Agent': hint};
  }

  Uri? get currentUrl {
    if (urls.isEmpty) return null;
    final index = _lineIndex.clamp(0, urls.length - 1);
    return urls[index];
  }

  /// Replaces the catalog (refresh) and keeps the current serial when present.
  bool setCatalog(EasyTvCatalog catalog) {
    final keepSerial = serialNum;
    _catalog = catalog;
    return openSerial(keepSerial);
  }

  /// Selects a channel by global serial number and resets the line index.
  bool openSerial(int serial) {
    final channel = _catalog.channelBySerial(serial);
    if (channel == null) {
      _channel = null;
      _lineIndex = 0;
      return false;
    }
    _channel = channel;
    _lineIndex = 0;
    return true;
  }

  /// Selects a channel by the drawer coordinates used in the source app.
  bool openAt(int groupIndex, int channelIndex) {
    final channel = _catalog.channelAt(groupIndex, channelIndex);
    if (channel == null) return false;
    _channel = channel;
    _lineIndex = 0;
    return true;
  }

  /// The source app clamps the requested line to the last available one.
  bool selectLine(int index) {
    if (urls.isEmpty) return false;
    final clamped = index.clamp(0, urls.length - 1);
    if (clamped == _lineIndex) return false;
    _lineIndex = clamped;
    return true;
  }

  /// Advances modulo the line count; `true` means it wrapped to the first line.
  bool switchLine() {
    if (urls.isEmpty) return false;
    _lineIndex = (_lineIndex + 1) % urls.length;
    return _lineIndex == 0;
  }

  /// Applies failover after a playback error.
  EasyTvLineFailure handleLineFailure() {
    if (urls.isEmpty) return EasyTvLineFailure.exhausted;
    if (_lineIndex + 1 < urls.length) {
      _lineIndex += 1;
      return EasyTvLineFailure.switched;
    }
    _lineIndex = urls.length - 1;
    return EasyTvLineFailure.exhausted;
  }

  /// Channel up/down walk the global serial order without wrapping.
  EasyTvChannel? nextChannel() {
    final next = _catalog.channelBySerial(serialNum + 1);
    if (next == null) return null;
    _channel = next;
    _lineIndex = 0;
    return next;
  }

  EasyTvChannel? previousChannel() {
    final previous = _catalog.channelBySerial(serialNum - 1);
    if (previous == null) return null;
    _channel = previous;
    _lineIndex = 0;
    return previous;
  }
}
