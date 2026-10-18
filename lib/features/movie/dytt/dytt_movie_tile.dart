import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:flutter/material.dart';

/// 列表 / 搜索结果里的一行。
///
/// 源工程列表项试图显示 `homePicUrl`，但列表接口根本不返回该字段，
/// 因此这里按接口实际数据只显示标题、发布时间与「续集/集数」前缀图标。
class DyttMovieTile extends StatelessWidget {
  const DyttMovieTile({required this.movie, required this.onTap, super.key});

  final DyttMovieDetail movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final publishTime = movie.publishTime.isEmpty
        ? '发布时间未知'
        : movie.publishTime;
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.movie_outlined)),
      title: Text(movie.name.isEmpty ? '未命名影片' : movie.name),
      subtitle: Text(publishTime),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
