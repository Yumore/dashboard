import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_page_state.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:flutter/material.dart';

/// 影片详情：海报、简介与可播放线路。
///
/// 源工程详情页只有海报、简介和一个空实现的下载 FAB；这里把
/// `downloadUrl` 解析成 HTTP(S) 线路，并交给宿主 `MediaPlaybackPage`。
class DyttDetailPage extends StatefulWidget {
  const DyttDetailPage({required this.api, required this.movie, super.key});

  final DyttApi api;

  /// 列表项或搜索结果；先用它渲染标题，再拉完整详情。
  final DyttMovieDetail movie;

  @override
  State<DyttDetailPage> createState() => DyttDetailPageState();
}
