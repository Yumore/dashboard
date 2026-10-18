import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_page_state.dart';
import 'package:flutter/material.dart';

/// 电影天堂模块入口：10 个分类标签 + 搜索。
///
/// 默认 `DyttApi` 使用 [DyttUnsupportedSignature]，进入后会明确显示签名
/// 缺口且不联网；测试或以后补上原生签名库时可注入自己的 `DyttApi`。
class DyttPage extends StatefulWidget {
  const DyttPage({this.api, super.key});

  final DyttApi? api;

  @override
  State<DyttPage> createState() => DyttPageState();
}
