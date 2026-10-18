import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_provider.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cache_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_strings.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterCachePage].
///
/// Every tag is queried through [EyepetizerFlutterBaseListProvider.query], which
/// returns `null` for a tag that was never cached — the same null the source's
/// feed fallback treated as "show the error page".
class EyepetizerFlutterCachePageState
    extends State<EyepetizerFlutterCachePage> {
  late final EyepetizerFlutterBaseListProvider _provider;
  final Map<String, int?> _counts = <String, int?>{};
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? EyepetizerFlutterBaseListProvider();
    unawaited(_load());
  }

  Future<void> _load() async {
    final counts = <String, int?>{};
    Object? error;
    for (final tag in EyepetizerFlutterStrings.cacheTags) {
      try {
        final data = await _provider.query(tag);
        counts[tag] = data?.itemList.length;
      } catch (failure) {
        error = failure;
      }
    }
    if (!mounted) return;
    setState(() {
      _counts
        ..clear()
        ..addAll(counts);
      _error = error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('本地缓存')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(
          '读取缓存失败：$_error',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }
    return ListView(
      children: EyepetizerFlutterStrings.cacheTags
          .map((tag) {
            final count = _counts[tag];
            return ListTile(
              title: Text(tag),
              subtitle: Text(count == null ? '无缓存' : '$count 条'),
            );
          })
          .toList(growable: false),
    );
  }
}
