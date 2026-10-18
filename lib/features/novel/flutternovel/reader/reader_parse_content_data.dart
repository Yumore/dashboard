import 'package:dashboard/features/novel/flutternovel/reader/content_state.dart';

/// A chapter's text handed to the pagination step.
///
/// Ported from the source's `ReaderParseContentDataValue`.
class ReaderParseContentData {
  ReaderParseContentData(
    this.content,
    this.novelId,
    this.title,
    this.chapterIndex,
  );

  ContentState contentState = ContentState.normal;

  String? content;
  String? title;
  String? novelId;
  int chapterIndex;
}
