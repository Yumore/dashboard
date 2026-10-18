/// Splits novel text into reader pages.
///
/// EasyMyGo laid a chapter out and paginated by measured text height inside its
/// reader view. The host port has no shared layout engine in the business layer,
/// so the substitution is a deterministic character budget that always breaks on
/// a paragraph boundary when one is available — same contract (an ordered list of
/// pages plus a current page index), stable and unit-testable.
class NovelPaginator {
  const NovelPaginator({this.maxChars = 1200});

  /// Soft limit for one page.
  final int maxChars;

  List<String> paginate(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (normalized.trim().isEmpty) return const <String>[];

    final pages = <String>[];
    final buffer = StringBuffer();
    var bufferLength = 0;

    void flush() {
      final page = buffer.toString().trimRight();
      if (page.isNotEmpty) pages.add(page);
      buffer.clear();
      bufferLength = 0;
    }

    for (final rawLine in normalized.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        if (bufferLength > 0) {
          buffer.write('\n');
          bufferLength += 1;
        }
        continue;
      }
      // A paragraph longer than a whole page is hard-split.
      if (line.length >= maxChars) {
        flush();
        for (var start = 0; start < line.length; start += maxChars) {
          final end = (start + maxChars).clamp(0, line.length);
          pages.add(line.substring(start, end));
        }
        continue;
      }
      if (bufferLength + line.length + 1 > maxChars) flush();
      if (bufferLength > 0) {
        buffer.write('\n');
        bufferLength += 1;
      }
      buffer.write(line);
      bufferLength += line.length;
    }
    flush();
    return pages;
  }
}
