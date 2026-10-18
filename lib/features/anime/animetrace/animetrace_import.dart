import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// What the importer does with one scraped anime.
enum AnimeTraceImportDecision {
  /// Its detail URL already exists in the local collection.
  skipDuplicateUrl,

  /// A different row with the same name exists and the user asked to skip
  /// duplicate names.
  skipDuplicateName,

  /// The row is new and should be inserted.
  insert,
}

/// Counters shown when an import finishes.
class AnimeTraceImportSummary {
  const AnimeTraceImportSummary({
    this.skipped = 0,
    this.inserted = 0,
    this.failed = 0,
    this.failedAnimes = const <AnimeTraceAnime>[],
  });

  final int skipped;
  final int inserted;
  final int failed;
  final List<AnimeTraceAnime> failedAnimes;

  AnimeTraceImportSummary copyWith({
    int? skipped,
    int? inserted,
    int? failed,
    List<AnimeTraceAnime>? failedAnimes,
  }) {
    return AnimeTraceImportSummary(
      skipped: skipped ?? this.skipped,
      inserted: inserted ?? this.inserted,
      failed: failed ?? this.failed,
      failedAnimes: failedAnimes ?? this.failedAnimes,
    );
  }

  /// `"3个已跳过，12个添加成功"` — each part only when non-zero, as in the
  /// source app's completion toast.
  String describe() {
    final parts = <String>[];
    if (skipped > 0) parts.add('$skipped个已跳过');
    if (inserted > 0) parts.add('$inserted个添加成功');
    if (failed > 0) parts.add('$failed个添加失败');
    if (parts.isEmpty) return '没有需要导入的内容';
    return parts.join('，');
  }
}

/// Pure core of the collection importer.
class AnimeTraceImport {
  const AnimeTraceImport._();

  /// Page count of [total] items at [pageSize] per page; `0` for no items.
  static int pageCount(int total, int pageSize) {
    if (total <= 0 || pageSize <= 0) return 0;
    return total % pageSize == 0 ? total ~/ pageSize : total ~/ pageSize + 1;
  }

  /// Decides what to do with [anime].
  ///
  /// [existingUrls] / [existingNames] are the locally collected values, so the
  /// function stays database-free.
  static AnimeTraceImportDecision decide(
    AnimeTraceAnime anime, {
    required Set<String> existingUrls,
    required Set<String> existingNames,
    bool skipDuplicateName = true,
  }) {
    final url = anime.animeUrl;
    if (url.isNotEmpty && existingUrls.contains(url)) {
      return AnimeTraceImportDecision.skipDuplicateUrl;
    }
    if (skipDuplicateName &&
        anime.animeName.isNotEmpty &&
        existingNames.contains(anime.animeName)) {
      return AnimeTraceImportDecision.skipDuplicateName;
    }
    return AnimeTraceImportDecision.insert;
  }

  /// The `[page]`-th slice (1-based) of [animes], or an empty list past the
  /// end.
  static List<AnimeTraceAnime> pageSlice(
    List<AnimeTraceAnime> animes, {
    required int page,
    required int pageSize,
  }) {
    if (page < 1 || pageSize < 1) return <AnimeTraceAnime>[];
    final start = (page - 1) * pageSize;
    if (start >= animes.length) return <AnimeTraceAnime>[];
    final end = start + pageSize > animes.length
        ? animes.length
        : start + pageSize;
    return animes.sublist(start, end);
  }
}
