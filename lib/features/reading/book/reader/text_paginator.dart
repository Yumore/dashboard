import 'package:dashboard/features/reading/book/entity/read_page.dart';
import 'package:dashboard/features/reading/book/entity/text_page.dart';
import 'package:dashboard/features/reading/book/reader/reader_settings.dart';
import 'package:dashboard/features/reading/book/reader/text_layout_engine.dart';

/// Outcome of a chapter pagination run (ABI v3).
class PaginateOutcome {
  final List<TextPage> pages;
  final bool complete;
  final int nextChar;
  final String engine;
  final int jobId;
  final String? fallbackReason;

  const PaginateOutcome({
    required this.pages,
    this.complete = true,
    this.nextChar = 0,
    this.engine = 'dart',
    this.jobId = 0,
    this.fallbackReason,
  });
}

/// Unified pagination entry point: metrics collection + layout + cancel.
///
/// Host port of `book/lib/model/reader/text_paginator.dart`. The source wrapped
/// `TextComposition`, which preferred a Rust pager and fell back to Dart; the
/// host has no native pager, so every path reports `engine: 'dart'` and
/// [fallbackReason] records why the native path was unavailable
/// (`native_unavailable`) for parity with the source diagnostics.
class TextPaginator {
  TextPaginator({TextLayoutEngine engine = const TextLayoutEngine()})
      : _engine = engine;

  final TextLayoutEngine _engine;

  int _nextJobId = 1;
  int _activeJobId = 0;

  /// Currently active job (0 = none).
  int get activeJobId => _activeJobId;

  /// Cancel any in-flight pagination job.
  void cancelActive() {
    if (_activeJobId == 0) return;
    _activeJobId = 0;
  }

  Future<List<TextPage>> paginate(
    ReadPage readPage, {
    bool shouldJustifyHeight = false,
  }) async {
    return paginateSync(readPage, shouldJustifyHeight: shouldJustifyHeight);
  }

  List<TextPage> paginateSync(
    ReadPage readPage, {
    bool shouldJustifyHeight = false,
  }) {
    return _engine.layout(
      readPage,
      params: layoutParams(shouldJustifyHeight: shouldJustifyHeight),
    );
  }

  /// First-page-first progressive pagination.
  ///
  /// Without a native pager there is no chunked backend, so this runs the Dart
  /// layout in one shot and still honours the cancel contract: a job superseded
  /// before completion returns `engine: 'cancelled'` with no pages.
  Future<PaginateOutcome> paginateProgressive(
    ReadPage readPage, {
    bool shouldJustifyHeight = false,
    void Function(List<TextPage> pages, bool complete)? onProgress,
    bool firstPageFirst = true,
    bool cancelPrevious = true,
  }) async {
    if (cancelPrevious) {
      cancelActive();
    }
    final jobId = _nextJobId++;
    _activeJobId = jobId;
    final text = readPage.chapterContent;
    try {
      final pages = await paginate(
        readPage,
        shouldJustifyHeight: shouldJustifyHeight,
      );
      if (_activeJobId != jobId) {
        return PaginateOutcome(
          pages: const [],
          complete: false,
          jobId: jobId,
          engine: 'cancelled',
          fallbackReason: 'cancelled',
        );
      }
      onProgress?.call(pages, true);
      return PaginateOutcome(
        pages: pages,
        complete: true,
        nextChar: text.length,
        engine: 'dart',
        jobId: jobId,
        fallbackReason: 'native_unavailable',
      );
    } finally {
      if (_activeJobId == jobId) _activeJobId = 0;
    }
  }

  Map<String, dynamic> layoutParams({bool shouldJustifyHeight = false}) {
    return ReaderSettings.layoutParams(
      shouldJustifyHeight: shouldJustifyHeight,
    );
  }

  /// Stable layout fingerprint for page-cache invalidation.
  ///
  /// Box sizes are rounded to integers to avoid thrashing on minor system-UI
  /// height jitter; font metrics keep their decimals.
  String layoutFingerprint({
    required Map<String, dynamic> layoutParams,
    required int contentLen,
    String contentSig = '',
  }) {
    String n(Object? v, {int decimals = 0}) {
      final d = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
      if (decimals <= 0) return d.round().toString();
      final f = d.toStringAsFixed(decimals);
      return f.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final fontSize = n(layoutParams['fontSize'], decimals: 1);
    final lineHeight = n(layoutParams['lineHeight'], decimals: 2);
    final paragraph = n(layoutParams['paragraph'], decimals: 1);
    final padH = n(layoutParams['padH'], decimals: 1);
    final boxW = n(layoutParams['boxW']);
    final boxH = n(layoutParams['boxH']);
    final fontFamily = '${layoutParams['fontFamily'] ?? ''}';
    final fontPath = '${layoutParams['fontPath'] ?? ''}';
    final justify = layoutParams['shouldJustifyHeight'] == true ? '1' : '0';
    final abi = '${layoutParams['abi'] ?? ReaderSettings.abiVersion}';
    final align = '${layoutParams['textAlign'] ?? 'justify'}';
    return 'abi$abi|$fontSize|$lineHeight|$paragraph|$padH|$boxW|$boxH|'
        '$fontFamily|$fontPath|$justify|$align|$contentLen|$contentSig';
  }

  /// Cheap content signature so same-length different bodies don't share cache.
  String contentSignature(String content) {
    if (content.isEmpty) return '0';
    // FNV-1a 32-bit over a sample of head/mid/tail code units.
    var hash = 0x811c9dc5;
    void mix(int unit) {
      hash ^= unit & 0xff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }

    final len = content.length;
    final step = len <= 256 ? 1 : (len ~/ 128);
    for (var i = 0; i < len; i += step) {
      mix(content.codeUnitAt(i));
    }
    mix(len & 0xff);
    mix((len >> 8) & 0xff);
    mix((len >> 16) & 0xff);
    return hash.toRadixString(16);
  }
}
