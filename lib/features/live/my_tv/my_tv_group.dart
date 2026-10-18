import 'package:dashboard/features/live/my_tv/my_tv_channel.dart';

/// An ordered playlist group (`group-title` for M3U, `#genre#` section for TVbox).
class MyTvGroup {
  const MyTvGroup({
    required this.index,
    required this.name,
    required this.channels,
  });

  final int index;
  final String name;
  final List<MyTvChannel> channels;

  @override
  String toString() => 'MyTvGroup($index, $name, ${channels.length})';
}
