import 'package:flutter/material.dart';

import '../models/pixez_illust.dart';
import 'pixez_illust_grid_state.dart';

/// Two-column illust grid with bottom-triggered paging.
class PixezIllustGrid extends StatefulWidget {
  const PixezIllustGrid({
    required this.illusts,
    this.onTap,
    this.onLoadMore,
    this.loading = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding = const EdgeInsets.all(12),
    super.key,
  });

  final List<PixezIllust> illusts;
  final void Function(PixezIllust illust)? onTap;
  final Future<void> Function()? onLoadMore;
  final bool loading;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  PixezIllustGridState createState() => PixezIllustGridState();
}
