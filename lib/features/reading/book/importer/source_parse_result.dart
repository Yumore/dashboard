
import 'package:dashboard/features/reading/book/model/book_source.dart';

/// Result of parsing a Legado book-source JSON payload.
class SourceParseResult {
  final List<BookSource> sources;
  final int skipped;
  final int duplicatesInBatch;

  const SourceParseResult({
    required this.sources,
    this.skipped = 0,
    this.duplicatesInBatch = 0,
  });

  int get count => sources.length;
}

/// Result of upserting sources into the local DB.
