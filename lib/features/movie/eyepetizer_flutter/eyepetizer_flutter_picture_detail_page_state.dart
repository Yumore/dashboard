import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_picture_detail_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_picture_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// State for [EyepetizerFlutterPictureDetailPage].
class EyepetizerFlutterPictureDetailPageState
    extends State<EyepetizerFlutterPictureDetailPage> {
  late final EyepetizerFlutterDetailRepository _repository;
  late final bool _ownsRepository;
  final PageController _pageController = PageController();

  EyepetizerFlutterDetail? _detail;
  Object? _error;
  bool _loading = true;

  /// The source's indicator is 1-based and starts at 1.
  int _index = 1;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EyepetizerFlutterDetailRepository();
    unawaited(_load());
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final detail = await _repository.getVideoDetail(
        widget.contentData.id ?? 0,
        resourceType: widget.contentData.resourceType,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
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
    final detail = _detail;
    final urls = detail?.urls ?? const <String>[];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.black,
          ),
          Expanded(child: _buildBody(detail, urls)),
        ],
      ),
    );
  }

  Widget _buildBody(EyepetizerFlutterDetail? detail, List<String> urls) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          '$_error',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }
    if (detail == null || urls.isEmpty) return Container();
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (index) => setState(() => _index = index + 1),
            itemBuilder: (context, index) => PhotoView(
              imageProvider: CachedNetworkImageProvider(urls[index]),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        '$_index/${urls.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 10,
                      child: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              EyepetizerFlutterPictureInfoWidget(data: detail),
            ],
          ),
        ),
      ],
    );
  }
}
