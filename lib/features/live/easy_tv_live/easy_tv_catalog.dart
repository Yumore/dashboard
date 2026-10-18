import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel_group.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_playlist_type.dart';

/// A parsed easy_tv_live playlist, porting `PlayChannelListModel`.
///
/// Groups keep playlist order and every channel carries its global serial
/// number plus `groupIndex` / `channelIndex`, which is what channel up/down and
/// the drawer use in the source app.
class EasyTvCatalog {
  const EasyTvCatalog({
    required this.type,
    required this.groups,
    this.epgUrl,
    this.uaHint = '',
  });

  final EasyTvPlaylistType type;
  final List<EasyTvChannelGroup> groups;
  final String? epgUrl;

  /// User-Agent the playlist asks for: either the `#UA-Hint` directive or the
  /// `ua` query parameter of the subscription URL.
  final String uaHint;

  List<EasyTvChannel> get channels => <EasyTvChannel>[
    for (final group in groups) ...group.channels,
  ];

  List<String> get groupNames => <String>[
    for (final group in groups) group.name,
  ];

  int get channelCount => channels.length;

  bool get isEmpty => channelCount == 0;

  EasyTvChannel? channelBySerial(int serialNum) {
    for (final channel in channels) {
      if (channel.serialNum == serialNum) return channel;
    }
    return null;
  }

  /// Resolves a channel by its coordinates in the catalog, guarding against
  /// stale indices kept by the source app after a playlist change.
  EasyTvChannel? channelAt(int groupIndex, int channelIndex) {
    if (groupIndex < 0 || groupIndex >= groups.length) return null;
    final channels = groups[groupIndex].channels;
    if (channelIndex < 0 || channelIndex >= channels.length) return null;
    return channels[channelIndex];
  }
}
