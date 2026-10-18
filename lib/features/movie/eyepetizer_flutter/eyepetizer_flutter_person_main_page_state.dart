import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_edit_person_data_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_home_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_header_view.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_model.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_photo_view_page.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterPersonMainPage].
class EyepetizerFlutterPersonMainPageState
    extends State<EyepetizerFlutterPersonMainPage>
    with TickerProviderStateMixin {
  late final EyepetizerFlutterPersonRepository _repository;
  late final bool _ownsRepository;
  final ScrollController _scrollController = ScrollController();

  EyepetizerFlutterPersonMainModel? _model;
  Object? _error;
  bool _loading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EyepetizerFlutterPersonRepository();
    unawaited(_load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final model = await _repository.getPersonMainPageData(
        widget.uid,
        widget.isMySelf,
      );
      if (!mounted) return;
      final tabs = model.tabInfo?.tabList ?? const [];
      _tabController?.dispose();
      setState(() {
        _model = model;
        _loading = false;
        _tabController = tabs.isEmpty
            ? null
            : TabController(length: tabs.length, vsync: this);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = _model;
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (model == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('开眼精选')),
        body: Center(
          child: Text(
            '$_error',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }
    final tabs = model.tabInfo?.tabList ?? const [];
    final controller = _tabController;
    if (controller == null || tabs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('开眼精选')),
        body: EyepetizerFlutterPersonMainHeaderView(
          data: model,
          isMySelf: widget.isMySelf,
          onEditPressed: _openEdit,
          onAvatarPressed: _openPhoto,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              title: const Text('开眼精选'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined),
                onPressed: () => Navigator.of(context).pop(),
              ),
              titleSpacing: -10,
              actions: const <Widget>[
                Icon(Icons.share),
                Icon(Icons.more_horiz),
              ],
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: 365,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: EyepetizerFlutterPersonMainHeaderView(
                  data: model,
                  isMySelf: widget.isMySelf,
                  onEditPressed: _openEdit,
                  onAvatarPressed: _openPhoto,
                ),
              ),
              bottom: TabBar(
                controller: controller,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: tabs
                    .map((tab) => Tab(text: tab.name ?? ''))
                    .toList(growable: false),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: controller,
          children: tabs
              .map(
                (tab) => EyepetizerFlutterPersonHomePage(
                  url: tab.apiUrl,
                  tabName: tab.name ?? '',
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _openEdit() async {
    final userInfo = _model?.userInfo;
    if (userInfo == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EyepetizerFlutterEditPersonDataPage(userInfo: userInfo),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  void _openPhoto() {
    final icon = _model?.userInfo?.icon;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EyepetizerFlutterPhotoViewPage(url: icon),
      ),
    );
  }
}
