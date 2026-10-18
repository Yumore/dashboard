

/// Result of parsing a Legado book-source JSON payload.
class SourceUpsertStats {
  final int inserted;
  final int updated;

  const SourceUpsertStats({required this.inserted, required this.updated});

  int get total => inserted + updated;
}

