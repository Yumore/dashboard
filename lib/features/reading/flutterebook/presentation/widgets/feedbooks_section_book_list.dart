import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_genre_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_card.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_section_header.dart';
import 'package:flutter/material.dart';

/// 源工程 Explore 页的 `_SectionBookList`：一个分类 = 标题 + 200 高的横向书列。
///
/// 每个分区自己抓一次该分类的 feed，源工程用 riverpod family provider 按
/// `link.href` 建实例；移植版由一个 controller 工厂给每个分区造一个
/// [FeedbooksGenreFeedController]。首屏书数少于 10 时隐藏 `See All`（源工程
/// 用 `ValueNotifier<int>` 只在第一次拿到数据时写入）。
class FeedbooksSectionBookList extends StatefulWidget {
  const FeedbooksSectionBookList({
    super.key,
    required this.link,
    required this.controllerFactory,
    this.onTapBook,
    this.onSeeAll,
  });

  final FeedbooksLink link;
  final FeedbooksGenreFeedController Function(String url) controllerFactory;
  final void Function(FeedbooksEntry entry, FeedbooksBookHeroTags tags)?
  onTapBook;
  final void Function(FeedbooksLink link)? onSeeAll;

  @override
  State<FeedbooksSectionBookList> createState() =>
      _FeedbooksSectionBookListState();
}

class _FeedbooksSectionBookListState extends State<FeedbooksSectionBookList> {
  late final FeedbooksGenreFeedController _controller = widget
      .controllerFactory(widget.link.href!);

  /// 当前分区拿到的书目数量。源工程用 `ValueNotifier<int>` 缓存并在构建时
  /// 写入；直接读控制器可以避免“首帧表头用旧计数、之后不再重建”的问题。
  int get _bookCount => _controller.books.length;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.fetch();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FeedbooksSectionHeader(
          link: widget.link,
          hideSeeAll: _bookCount < 10,
          onSeeAll: widget.onSeeAll,
        ),
        const SizedBox(height: 10.0),
        SizedBox(
          height: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _body(),
          ),
        ),
      ],
    );
  }

  Widget _body() {
    if (_controller.error != null) {
      return FeedbooksErrorWidget(refreshCallBack: _controller.fetch);
    }
    final FeedbooksGenreFeedData? data = _controller.data;
    if (data == null) {
      return const FeedbooksLoadingWidget();
    }
    final List<FeedbooksEntry> books = data.books;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      scrollDirection: Axis.horizontal,
      itemCount: books.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final FeedbooksEntry entry = books[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: FeedbooksBookCard(
            img: entry.link![1].href!,
            entry: entry,
            onTap: (FeedbooksBookHeroTags tags) =>
                widget.onTapBook?.call(entry, tags),
          ),
        );
      },
    );
  }
}
