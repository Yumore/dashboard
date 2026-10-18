import 'dart:ui' as ui;

import 'package:dashboard/features/novel/flutternovel/reader/reader_page_content_config.dart';
import 'package:flutter/painting.dart';

/// Splits a chapter's text into pages for the reader.
///
/// Ported from the source's `ReaderContentProvider.getChapterPageContentConfigList`
/// (helper_reader_content.dart). The source ran this on a `flutter_isolate`
/// worker; the host has no such dependency, so the port runs the same maths on
/// the main isolate. The algorithm is unchanged: content is split on newlines,
/// each paragraph is laid out with a [TextPainter] to the page width, and the
/// page is filled while the consumed height stays under the page height. A
/// paragraph that does not fit is cut at the measured caret offset and the
/// remainder is pushed back for the next page.
///
/// Two robustness guards were added because the source version could spin
/// forever: degenerate geometry (non-positive page size / font / line height)
/// returns no pages, and a page that cannot consume any paragraph (line height
/// >= page height) takes the first paragraph whole so each iteration makes
/// progress. A hard page cap derived from the text length backs both up.
class ReaderContentProvider {
  ReaderContentProvider._();

  static List<ReaderPageContentConfig> getChapterPageContentConfigList(
    int targetChapterId,
    String? content,
    double height,
    double width,
    int fontSize,
    int lineHeight,
    int paragraphSpacing,
  ) {
    if (content == null || content.isEmpty) {
      return <ReaderPageContentConfig>[];
    }
    if (height <= 0 || width <= 0 || fontSize <= 0 || lineHeight <= 0) {
      return <ReaderPageContentConfig>[];
    }

    final paragraphs = content.split('\n');
    final pageConfigList = <ReaderPageContentConfig>[];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final maxPages = content.length + 1;
    var currentHeight = 0.0;
    var pageIndex = 0;

    while (paragraphs.isNotEmpty && pageConfigList.length < maxPages) {
      final config = ReaderPageContentConfig()
        ..currentChapterId = targetChapterId
        ..currentContentFontSize = fontSize
        ..currentContentLineHeight = lineHeight
        ..currentContentParagraphSpacing = paragraphSpacing
        ..currentPageIndex = pageIndex;

      while (currentHeight < height) {
        /// The source stopped once the next line could not fit, or the chapter
        /// ran out of paragraphs.
        if (currentHeight + lineHeight >= height || paragraphs.isEmpty) {
          break;
        }

        final tempContent = paragraphs.first;

        textPainter.text = TextSpan(
          text: tempContent,
          style: TextStyle(
            fontSize: fontSize.toDouble(),
            height: lineHeight / fontSize,
          ),
        );
        textPainter.layout(maxWidth: width);

        /// The source subtracted one line height because
        /// `getPositionForOffset` still reports a caret inside a partially
        /// visible line. `remaining` is strictly positive here because of the
        /// break above.
        final remaining = height - currentHeight - lineHeight;
        final endOffset = textPainter
            .getPositionForOffset(Offset(width, remaining))
            .offset;

        final lineCount = textPainter.computeLineMetrics().length;

        if (endOffset < tempContent.length) {
          /// The paragraph does not fit: keep the visible slice and push the
          /// remainder back to the front of the queue. The page is now full.
          config.paragraphContents.add(tempContent.substring(0, endOffset));
          paragraphs[0] = tempContent.substring(endOffset);
          currentHeight = height;
        } else {
          paragraphs.removeAt(0);
          currentHeight += lineHeight * lineCount;
          currentHeight += paragraphSpacing;
          config.paragraphContents.add(tempContent);
        }
      }

      if (config.paragraphContents.isEmpty && paragraphs.isNotEmpty) {
        config.paragraphContents.add(paragraphs.removeAt(0));

        /// Cannot happen for positive geometry, but keep the loop honest.
        if (currentHeight == 0 && lineHeight >= height) {
          currentHeight = height;
        }
      }

      pageConfigList.add(config);
      currentHeight = 0;
      pageIndex++;
    }

    return pageConfigList;
  }

  /// The source's page renderer drew each page into a [ui.Picture]; this helper
  /// keeps that behaviour available without the isolate.
  static ui.Picture recordPicture(void Function(ui.Canvas canvas) paint) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    paint(canvas);
    return recorder.endRecording();
  }
}
