import 'pixez_search_options.dart';

/// Parameters of `/v1/search/illust` and `/v1/search/novel`.
///
/// pixiv expects unpadded `yyyy-m-d` date strings (source `getFormatDate`),
/// not ISO dates.
class PixezSearchQuery {
  const PixezSearchQuery({
    required this.word,
    this.sort = PixezSearchOptions.defaultSort,
    this.searchTarget = PixezSearchOptions.defaultTarget,
    this.startDate,
    this.endDate,
    this.bookmarkNum,
  });

  final String word;
  final String? sort;
  final String? searchTarget;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? bookmarkNum;

  static String formatDate(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (searchTarget != null && searchTarget!.isNotEmpty)
        'search_target': searchTarget,
      if (startDate != null) 'start_date': formatDate(startDate!),
      if (endDate != null) 'end_date': formatDate(endDate!),
      if (bookmarkNum != null) 'bookmark_num': bookmarkNum,
      'word': word,
    };
  }
}
