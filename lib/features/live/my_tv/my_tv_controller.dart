import 'package:dashboard/features/live/my_tv/my_tv_channel.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_guide.dart';
import 'package:dashboard/features/live/my_tv/my_tv_group.dart';
import 'package:dashboard/features/live/my_tv/my_tv_timer.dart';
import 'package:flutter/foundation.dart';

/// Channel navigation state for the my_tv module.
///
/// Ports the source app's store behaviour without mobx: previous/next channel,
/// previous/next group with wrap-around, and numeric channel entry with an
/// auto-confirm timer. Both the clock and the timer are injectable so tests
/// never wait on real time.
class MyTvController extends ChangeNotifier {
  MyTvController({
    List<MyTvGroup> groups = const [],
    MyTvEpgGuide? guide,
    DateTime Function()? now,
    MyTvTimerFactory? timerFactory,
    this.confirmSeconds = 4,
  }) : _groups = groups,
       _guide = guide,
       _now = now ?? DateTime.now,
       _timerFactory = timerFactory ?? defaultMyTvTimerFactory {
    _rebuildChannels();
    _current = _channels.isEmpty ? null : _channels.first;
  }

  final MyTvTimerFactory _timerFactory;
  final DateTime Function() _now;

  /// Seconds after the first digit that numeric entry is auto-confirmed.
  final int confirmSeconds;

  List<MyTvGroup> _groups;
  List<MyTvChannel> _channels = const [];
  MyTvChannel? _current;
  MyTvEpgGuide? _guide;
  String _channelNo = '';
  MyTvTimer? _timer;

  List<MyTvGroup> get groups => _groups;
  List<MyTvChannel> get channels => _channels;
  MyTvChannel? get current => _current;
  MyTvEpgGuide? get guide => _guide;

  /// Digits typed so far for numeric channel entry.
  String get channelNo => _channelNo;

  bool get hasChannels => _channels.isNotEmpty;

  void setGroups(List<MyTvGroup> groups) {
    _groups = groups;
    _rebuildChannels();
    _current = _channels.isEmpty ? null : _channels.first;
    _clearPendingInput();
    notifyListeners();
  }

  void setGuide(MyTvEpgGuide? guide) {
    _guide = guide;
    notifyListeners();
  }

  void select(MyTvChannel? channel) {
    if (channel == null || identical(channel, _current)) return;
    _current = channel;
    notifyListeners();
  }

  MyTvChannel? previousChannel() {
    if (_channels.isEmpty) return null;
    final index = _indexOfCurrent();
    final target = index <= 0 ? _channels.length - 1 : index - 1;
    _current = _channels[target];
    notifyListeners();
    return _current;
  }

  MyTvChannel? nextChannel() {
    if (_channels.isEmpty) return null;
    final index = _indexOfCurrent();
    final target = index >= _channels.length - 1 ? 0 : index + 1;
    _current = _channels[target];
    notifyListeners();
    return _current;
  }

  MyTvChannel? previousGroupChannel() {
    final group = _adjacentGroup(-1);
    return _selectFirstOf(group);
  }

  MyTvChannel? nextGroupChannel() {
    final group = _adjacentGroup(1);
    return _selectFirstOf(group);
  }

  /// Appends a digit and (re)arms the auto-confirm timer.
  ///
  /// Like the source app, the delay shrinks with each digit so confirmation
  /// lands [confirmSeconds] after the first digit.
  void inputChannelNo(String digit) {
    if (digit.isEmpty) return;
    _timer?.cancel();
    _channelNo += digit;
    final remaining = confirmSeconds - _channelNo.length;
    _timer = _timerFactory(
      Duration(seconds: remaining < 0 ? 0 : remaining),
      _confirmChannelNo,
    );
    notifyListeners();
  }

  /// Cancels any pending numeric entry and clears the typed digits.
  void clearPendingChannelInput() {
    if (_channelNo.isEmpty && _timer == null) return;
    _clearPendingInput();
    notifyListeners();
  }

  /// Current/next programme titles for [channel], empty strings when unknown.
  ({String current, String next}) programmesFor(MyTvChannel channel) {
    final guide = _guide;
    if (guide == null) return (current: '', next: '');
    final now = _now().millisecondsSinceEpoch;
    return (
      current: guide.currentAt(channel.tvgName, now)?.title ?? '',
      next: guide.nextAt(channel.tvgName, now)?.title ?? '',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _confirmChannelNo() {
    final number = int.tryParse(_channelNo);
    _channelNo = '';
    _timer = null;
    if (number != null) {
      for (final channel in _channels) {
        if (channel.number == number) {
          _current = channel;
          break;
        }
      }
    }
    notifyListeners();
  }

  void _clearPendingInput() {
    _timer?.cancel();
    _timer = null;
    _channelNo = '';
  }

  void _rebuildChannels() {
    _channels = [for (final group in _groups) ...group.channels];
  }

  int _indexOfCurrent() {
    final current = _current;
    if (current == null) return -1;
    return _channels.indexOf(current);
  }

  int _currentGroupIndex() {
    final group = _current?.group;
    if (group == null) return 0;
    final index = _groups.indexWhere((item) => item.name == group);
    return index < 0 ? 0 : index;
  }

  /// Group [step] positions away, wrapping; skips empty groups.
  MyTvGroup? _adjacentGroup(int step) {
    if (_groups.isEmpty) return null;
    var index = _currentGroupIndex();
    for (var attempt = 0; attempt < _groups.length; attempt++) {
      index = (index + step) % _groups.length;
      final group = _groups[index];
      if (group.channels.isNotEmpty) return group;
    }
    return null;
  }

  MyTvChannel? _selectFirstOf(MyTvGroup? group) {
    if (group == null || group.channels.isEmpty) return _current;
    _current = group.channels.first;
    notifyListeners();
    return _current;
  }
}
