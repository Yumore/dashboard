/// One page of a chapter: the paragraphs (and paragraph fragments) that fit.
///
/// Ported from the source's `ReaderChapterPageContentConfig`. The JSON keys are
/// kept identical (`paragraphConfigs`) because the source shipped these through
/// an isolate as JSON; the port keeps the same shape so cached/parsed pages stay
/// interchangeable with what the source would have produced.
class ReaderPageContentConfig {
  int? currentContentFontSize;
  int? currentContentLineHeight;
  int? currentContentParagraphSpacing;

  int? currentPageIndex;
  int? currentChapterId;

  List<String> paragraphContents = <String>[];

  ReaderPageContentConfig();

  ReaderPageContentConfig.fromJson(Map<String, dynamic> map) {
    currentContentFontSize = _asInt(map['currentContentFontSize']);
    currentContentLineHeight = _asInt(map['currentContentLineHeight']);
    currentContentParagraphSpacing = _asInt(
      map['currentContentParagraphSpacing'],
    );
    currentPageIndex = _asInt(map['currentPageIndex']);
    currentChapterId = _asInt(map['currentChapterId']);
    paragraphContents =
        (map['paragraphConfigs'] as List?)?.map((e) => '$e').toList() ??
        <String>[];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'currentContentFontSize': currentContentFontSize,
    'currentContentLineHeight': currentContentLineHeight,
    'currentContentParagraphSpacing': currentContentParagraphSpacing,
    'currentPageIndex': currentPageIndex,
    'currentChapterId': currentChapterId,
    'paragraphConfigs': paragraphContents,
  };

  /// The text this page draws, in order.
  String get text => paragraphContents.join('\n');

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderPageContentConfig &&
          currentContentFontSize == other.currentContentFontSize &&
          currentContentLineHeight == other.currentContentLineHeight &&
          currentContentParagraphSpacing ==
              other.currentContentParagraphSpacing &&
          currentPageIndex == other.currentPageIndex &&
          currentChapterId == other.currentChapterId &&
          _sameParagraphs(paragraphContents, other.paragraphContents);

  @override
  int get hashCode => Object.hash(
    currentContentFontSize,
    currentContentLineHeight,
    currentContentParagraphSpacing,
    currentPageIndex,
    currentChapterId,
    Object.hashAll(paragraphContents),
  );

  static bool _sameParagraphs(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
