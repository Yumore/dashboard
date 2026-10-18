import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_detail_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_widget_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_load_state.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_status_view.dart';
import 'package:flutter/material.dart';

class EyepetizerCategoryPageState extends State<EyepetizerCategoryPage> {
  late final EyepetizerApi _api;
  late final bool _ownsApi;

  final EyepetizerLoadState<List<EyepetizerCategory>> _state =
      EyepetizerLoadState<List<EyepetizerCategory>>();

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? EyepetizerApi();
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _state.loading = true;
      _state.error = null;
    });
    try {
      final categories = await _api.categories();
      if (!mounted) return;
      setState(() {
        _state.data = categories;
        _state.loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _state.loading = false;
        _state.error = error is EyepetizerException
            ? error.message
            : '分类加载失败，请重试';
      });
    }
  }

  void _open(EyepetizerCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            EyepetizerCategoryDetailPage(category: category, api: _api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分类')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_state.loading) return const EyepetizerStatusView.loading();
    final error = _state.error;
    if (error != null) {
      return EyepetizerStatusView.error(error, onRetry: _load);
    }
    final categories = _state.data ?? const <EyepetizerCategory>[];
    if (categories.isEmpty) {
      return const EyepetizerStatusView.empty('没有可浏览的分类');
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return EyepetizerCategoryWidgetItem(
            category: category,
            onTap: () => _open(category),
          );
        },
      ),
    );
  }
}
