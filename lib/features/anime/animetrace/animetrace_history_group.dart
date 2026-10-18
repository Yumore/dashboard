import 'package:dashboard/features/anime/animetrace/animetrace_history_record.dart';

/// All history of one calendar day, newest day first in the history page.
class AnimeTraceHistoryGroup {
  AnimeTraceHistoryGroup(this.date, List<AnimeTraceHistoryRecord>? records)
    : records = records ?? <AnimeTraceHistoryRecord>[];

  /// `YYYY-MM-DD` (or `YYYY-MM` / `YYYY` when the page groups coarser).
  final String date;
  final List<AnimeTraceHistoryRecord> records;

  @override
  String toString() =>
      'AnimeTraceHistoryGroup($date, records=${records.length})';
}
