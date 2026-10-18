import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_error_button.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_season.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeOneSchedulePageState extends State<AnimeOneSchedulePage>
    with SingleTickerProviderStateMixin {
  static const List<String> weekdayLabels = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  late final AnimeOneSiteClient _client;
  AnimeOneSiteClient? _ownedClient;
  late final AnimeOneWatchStore _store;
  late final TabController tabController;

  List<AnimeOneSchedule> schedules = [];
  AnimeOneSeason? season;
  String error = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? (_ownedClient = AnimeOneSiteClient());
    _store = widget.watchStore ?? AnimeOneWatchStore();
    season = AnimeOneSeason(DateTime.now());
    tabController = TabController(
      length: weekdayLabels.length,
      initialIndex: DateTime.now().weekday - 1,
      vsync: this,
    );
    _load();
  }

  @override
  void dispose() {
    tabController.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    final current = season;
    if (current == null) return;
    setState(() {
      loading = true;
      error = '';
    });
    final result = await _client.getSchedule(current);
    if (!mounted) return;
    setState(() {
      schedules = result.schedules;
      loading = false;
      if (result.schedules.isEmpty) {
        error = _client.blocked ? '访问被站点拒绝，请稍后再试' : '暂时没有新番信息';
      }
    });
  }

  /// 当天（周一 = 1 ... 周日 = 7）的新番。
  List<AnimeOneSchedule> schedulesFor(int weekday) =>
      schedules.where((item) => item.weekday == weekday).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(season?.name ?? '新番表'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: [for (final label in weekdayLabels) Tab(text: label)],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? AnimeOneErrorButton(message: error, onRetry: _load)
          : TabBarView(
              controller: tabController,
              children: [
                for (
                  var weekday = 1;
                  weekday <= weekdayLabels.length;
                  weekday++
                )
                  _renderDay(weekday),
              ],
            ),
    );
  }

  Widget _renderDay(int weekday) {
    final items = schedulesFor(weekday);
    if (items.isEmpty) {
      return const Center(child: Text('今天没有新番'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: item.link == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AnimeOneDetailPage(
                        link: item.link!,
                        title: item.name,
                        seasonal: true,
                        client: widget.client,
                        watchStore: _store,
                      ),
                    ),
                  );
                },
        );
      },
    );
  }
}
