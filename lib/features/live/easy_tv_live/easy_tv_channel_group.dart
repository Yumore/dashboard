import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel.dart';

/// A playlist group / category, mirroring the source app's `PlayModel`.
class EasyTvChannelGroup {
  const EasyTvChannelGroup({
    required this.name,
    required this.channels,
    this.index = 0,
  });

  final String name;
  final List<EasyTvChannel> channels;

  /// Position of the group in the parsed catalog, matching
  /// [EasyTvChannel.groupIndex].
  final int index;

  bool get isEmpty => channels.isEmpty;
}
