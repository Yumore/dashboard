import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_bloc.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_recommend_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_footer_view.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_load_status.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_picture_detail_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_refresh_list_view.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_staggered_view_card.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterCommunityRecommendPage].
class EyepetizerFlutterCommunityRecommendPageState
    extends State<EyepetizerFlutterCommunityRecommendPage>
    with AutomaticKeepAliveClientMixin {
  late final EyepetizerFlutterCommunityBloc _bloc;
  late final ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bloc = EyepetizerFlutterCommunityBloc(repository: widget.repository);
    _scrollController = ScrollController();
    unawaited(_bloc.refresh());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _bloc,
      builder: (context, _) => EyepetizerFlutterRefreshListView(
        scrollController: _scrollController,
        onRefresh: ({bool isReload = true}) => _bloc.refresh(),
        onLoadMore: () => unawaited(_bloc.loadMore()),
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          if (index == 1) {
            return EyepetizerFlutterFooterView(loadStatus: _bloc.loadStatus);
          }
          return EyepetizerFlutterStaggeredViewCard(
            list: _bloc.items,
            onPictureTap: _openPictureDetail,
            onVideoTap: _reportOutOfScopeVideo,
          );
        },
      ),
    );
  }

  /// The source's `itemCount: data == null ? 0 : 2` — index 0 is the card grid,
  /// index 1 the footer. The footer also appears while the first page loads, so
  /// the spinner is visible immediately.
  int get _itemCount {
    final isLoading = _bloc.loadStatus == EyepetizerFlutterLoadStatus.loading;
    return (_bloc.items.isNotEmpty || isLoading) ? 2 : 0;
  }

  void _openPictureDetail(EyepetizerFlutterContentData content) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EyepetizerFlutterPictureDetailPage(contentData: content),
      ),
    );
  }

  /// `ugc_video` cards pointed at the video-detail route, which belongs to the
  /// already-ported `lib/features/movie/eyepetizer/` surface. This module must
  /// not import it, so the tap reports the target instead of navigating.
  void _reportOutOfScopeVideo(int id) {
    AppToast.show(msg: '视频详情由 eyepetizer 模块提供（id: $id）');
  }
}
