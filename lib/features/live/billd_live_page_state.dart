import 'package:dashboard/features/live/billd_live_page.dart';
import 'package:dashboard/features/live/billd_live_repository.dart';
import 'package:dashboard/features/live/billd_live_room.dart';
import 'package:flutter/material.dart';

class BilldLivePageState extends State<BilldLivePage> {
  late final BilldLiveRepository _repository;
  late Future<List<BilldLiveRoom>> _rooms;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BilldLiveRepository();
    _rooms = _repository.load();
  }

  Future<void> _refresh() async {
    setState(() => _rooms = _repository.load());
    try {
      await _rooms;
    } catch (_) {
      // FutureBuilder renders the error state after the refresh completes.
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const names = ['首页', '排行', '分区', '我的'];
    const iconNames = ['home', 'rank', 'area', 'user'];
    return Scaffold(
      appBar: AppBar(title: Text('Billd 直播 · ${names[_tab]}')),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tab,
        onTap: (index) => setState(() => _tab = index),
        items: [
          for (var index = 0; index < names.length; index++)
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/billd_live/tabbar/${iconNames[index]}.png',
                width: 20,
              ),
              activeIcon: Image.asset(
                'assets/billd_live/tabbar/${iconNames[index]}_active.png',
                width: 20,
              ),
              label: names[index],
            ),
        ],
      ),
      body: _tab == 0
          ? _home()
          : Center(child: Text('暂无${names[_tab]}内容')),
    );
  }

  Widget _home() {
    return FutureBuilder<List<BilldLiveRoom>>(
      future: _rooms,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('加载失败：${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: snapshot.data!.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('暂无正在直播的房间')),
                  ],
                )
              : ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];
                    return ListTile(
                      leading: room.cover == null || !room.cover!.hasScheme
                          ? const Icon(Icons.live_tv_outlined)
                          : Image.network(
                              room.cover.toString(),
                              width: 48,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.live_tv_outlined),
                            ),
                      title: Text(room.title),
                      subtitle: room.description.isEmpty
                          ? null
                          : Text(room.description),
                      trailing: const Icon(Icons.live_tv_outlined),
                    );
                  },
                ),
        );
      },
    );
  }
}
