import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_book_details_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_list_item.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:flutter/material.dart';

/// 源工程详情页的 `_MoreBooksFromAuthor`：按作者 feed 拉相关书目。
///
/// 三种分支照抄源工程：
///  * feed 里没有 entry → 居中 `Empty`；
///  * 只有一条且就是当前这本 → “oops, there's no other book from this
///    author available”；
///  * 其余情况渲染列表，并跳过当前这本。
class FeedbooksMoreBooksFromAuthor extends StatefulWidget {
  const FeedbooksMoreBooksFromAuthor({
    super.key,
    required this.entry,
    required this.authorUrl,
    required this.controllerFactory,
    this.onTapBook,
  });

  final FeedbooksEntry entry;
  final String authorUrl;
  final FeedbooksBookDetailsController Function(String authorUrl)
  controllerFactory;
  final void Function(FeedbooksEntry entry, FeedbooksBookHeroTags tags)?
  onTapBook;

  @override
  State<FeedbooksMoreBooksFromAuthor> createState() =>
      _FeedbooksMoreBooksFromAuthorState();
}

class _FeedbooksMoreBooksFromAuthorState
    extends State<FeedbooksMoreBooksFromAuthor> {
  late final FeedbooksBookDetailsController _controller = widget
      .controllerFactory(widget.authorUrl);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.fetch();
  }

  @override
  void didUpdateWidget(covariant FeedbooksMoreBooksFromAuthor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorUrl != widget.authorUrl) {
      _controller.fetch();
    }
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
    if (_controller.error != null) {
      return FeedbooksErrorWidget(refreshCallBack: _controller.fetch);
    }
    final FeedbooksCategoryFeed? related = _controller.feed;
    if (related == null) {
      return const FeedbooksLoadingWidget();
    }
    final List<FeedbooksEntry>? entries = related.feed?.entry;
    if (entries == null || entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text('Empty'),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final FeedbooksEntry entry = entries[index];
        final bool isSingleEntry = entries.length == 1;
        if (entry.id!.t == widget.entry.id!.t && isSingleEntry) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Text(
                "oops, there's no other book from this author available",
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (entry.id!.t == widget.entry.id!.t) {
          // Skip rendering the current entry.
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: FeedbooksBookListItem(
            entry: entry,
            onTap: (FeedbooksBookHeroTags tags) =>
                widget.onTapBook?.call(entry, tags),
          ),
        );
      },
    );
  }
}
