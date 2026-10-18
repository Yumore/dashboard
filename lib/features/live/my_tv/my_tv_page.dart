import 'package:dashboard/features/live/my_tv/my_tv_controller.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_repository.dart';
import 'package:dashboard/features/live/my_tv/my_tv_page_state.dart';
import 'package:dashboard/features/live/my_tv/my_tv_playlist_repository.dart';
import 'package:flutter/material.dart';

/// my_tv: IPTV live channels with group/channel navigation and XMLTV EPG.
///
/// Dependencies are injectable so widget tests can supply a preloaded
/// [MyTvController] and avoid any network access.
class MyTvPage extends StatefulWidget {
  const MyTvPage({
    super.key,
    this.controller,
    this.playlistRepository,
    this.epgRepository,
    this.simplify = false,
  });

  final MyTvController? controller;
  final MyTvPlaylistRepository? playlistRepository;
  final MyTvEpgRepository? epgRepository;
  final bool simplify;

  @override
  State<MyTvPage> createState() => MyTvPageState();
}
