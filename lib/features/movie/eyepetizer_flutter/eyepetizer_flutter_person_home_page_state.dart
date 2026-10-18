import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_home_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_view_card_util.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterPersonHomePage].
class EyepetizerFlutterPersonHomePageState
    extends State<EyepetizerFlutterPersonHomePage>
    with AutomaticKeepAliveClientMixin {
  late final EyepetizerFlutterPersonRepository _repository;
  late final bool _ownsRepository;

  List<EyepetizerFlutterItem> _items = const <EyepetizerFlutterItem>[];
  Object? _error;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EyepetizerFlutterPersonRepository();
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _repository.getPersonHomePageData(widget.url ?? '');
      if (!mounted) return;
      setState(() {
        _items = data.itemList;
        _loading = false;
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
    super.build(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          '$_error',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      key: PageStorageKey<String>(widget.tabName),
      padding: EdgeInsets.zero,
      itemCount: _items.length,
      itemBuilder: (context, index) =>
          EyepetizerFlutterViewCardUtil.getViewCard(_items[index]),
    );
  }
}
