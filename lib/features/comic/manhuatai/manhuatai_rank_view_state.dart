import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_option.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_types.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiRankViewState extends State<ManhuataiRankView> {
  bool _loading = true;
  String? _error;
  ManhuataiRankTypes _types = ManhuataiRankTypes.empty;
  List<ManhuataiRankComic> _comics = <ManhuataiRankComic>[];
  String _sortType = '';
  String _timeType = 'week';
  bool _loadingRank = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final types = await widget.source.rankTypes();
      final rankTypes = types.data.rankTypeList;
      final selected = _sortType.isNotEmpty
          ? _sortType
          : (rankTypes.isEmpty ? 'heat' : rankTypes.first.value);
      if (!mounted) {
        return;
      }
      setState(() {
        _types = types;
        _sortType = selected;
        _loading = false;
      });
      await _loadRank();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _loadRank() async {
    if (_sortType.isEmpty) {
      return;
    }
    setState(() => _loadingRank = true);
    try {
      final detail = await widget.source.rankDetail(
        sortType: _sortType,
        timeType: _timeType,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _comics = detail.data;
        _loadingRank = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _comics = <ManhuataiRankComic>[];
        _loadingRank = false;
      });
    }
  }

  Widget _optionRow(
    List<ManhuataiRankOption> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          return Center(
            child: ChoiceChip(
              label: Text(option.name),
              selected: option.value == selected,
              onSelected: (_) => onSelected(option.value),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ManhuataiStatusView(loading: true);
    }
    if (_error != null) {
      return ManhuataiStatusView(message: _error, onRetry: _load);
    }
    final options = _types.data;
    return Column(
      children: <Widget>[
        if (options.rankTypeList.isNotEmpty)
          _optionRow(options.rankTypeList, _sortType, (value) {
            setState(() => _sortType = value);
            _loadRank();
          }),
        if (options.timeTypeList.isNotEmpty)
          _optionRow(options.timeTypeList, _timeType, (value) {
            setState(() => _timeType = value);
            _loadRank();
          }),
        const Divider(height: 1),
        Expanded(
          child: _loadingRank
              ? const ManhuataiStatusView(loading: true)
              : _comics.isEmpty
                  ? ManhuataiStatusView(message: '暂无榜单', onRetry: _loadRank)
                  : ListView.builder(
                      itemCount: _comics.length,
                      itemBuilder: (context, index) => ManhuataiRankTile(
                        rank: index + 1,
                        comic: _comics[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ManhuataiDetailPage(
                                comicId: _comics[index].comicId,
                                source: widget.source,
                                store: widget.store,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
