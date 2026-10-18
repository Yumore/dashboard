import 'package:dashboard/features/reading/book/entity/read_page.dart';
import 'package:dashboard/features/reading/book/entity/text_line.dart';
import 'package:dashboard/features/reading/book/entity/text_page.dart';
import 'package:flutter/painting.dart';

/// Pure-Flutter text pagination (ABI v3, semantic lines).
///
/// Host port of the Dart fallback in `book/lib/common/text_composition.dart`.
/// The source project preferred a Rust `book_pager` over FFI and used this
/// algorithm only as fallback; the host root pubspec has no FFI/Rust pager, so
/// this *is* the engine. Behaviours preserved verbatim:
///
/// * measure width is `columnWidth * 0.99` (paint-side slack);
/// * a paragraph is consumed with `TextPainter.getPositionForOffset` at
///   `Offset(measureWidth, 1)`; a zero/negative offset forces at least one
///   grapheme (surrogate pairs counted as two code units);
/// * a page breaks when `top > boxH - fontSize * lineHeight`;
/// * `justify` is true only for a full non-final line wider than
///   `width - fontSize` (and at least two runes);
/// * `shouldJustifyHeight` vertically redistributes line tops via
///   [TextLine.justifyDy];
/// * an empty paragraph list still yields one empty page.
class TextLayoutEngine {
  const TextLayoutEngine();

  List<TextPage> layout(
    ReadPage readPage, {
    required Map<String, dynamic> params,
  }) {
    final fontSize = (params['fontSize'] as num?)?.toDouble() ?? 14;
    final lineHeight = (params['lineHeight'] as num?)?.toDouble() ?? 1.0;
    final paragraph = (params['paragraph'] as num?)?.toDouble() ?? 0;
    final padH = (params['padH'] as num?)?.toDouble() ?? 0;
    final boxW = (params['boxW'] as num?)?.toDouble() ?? 360;
    final boxH = (params['boxH'] as num?)?.toDouble() ?? 640;
    final fontFamily = '${params['fontFamily'] ?? ''}';
    final shouldJustifyHeight = params['shouldJustifyHeight'] == true;

    final style = TextStyle(
      locale: const Locale('zh_CN'),
      fontFamily: fontFamily.isEmpty ? null : fontFamily,
      fontSize: fontSize,
      height: lineHeight,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final width = boxW - padH * 2;
    final width2 = width - fontSize;
    final height = boxH;
    final height2 = height - fontSize * lineHeight;
    final lineBoxH = fontSize * lineHeight;

    var lines = <TextLine>[];
    var top = 0.0;
    var startLine = 0;
    var pageIndex = 0;
    final pages = <TextPage>[];

    void newPage() {
      if (shouldJustifyHeight) {
        final len = lines.length - startLine;
        if (len > 1) {
          final justifyGap = (height - top) / (len - 1);
          if (justifyGap.isFinite && justifyGap > 0) {
            for (var i = 0; i < len; i++) {
              lines[i + startLine].justifyDy(justifyGap * i);
            }
          }
        }
      }
      final pageLines = lines;
      final pageH =
          pageLines.isEmpty ? 0.0 : pageLines.last.top + pageLines.last.height;
      pages.add(TextPage(pageLines, pageH, pageIndex: pageIndex));
      pageIndex++;
      lines = <TextLine>[];
      top = 0.0;
      startLine = 0;
    }

    void newParagraph() {
      if (top > height2) {
        newPage();
      } else {
        top += paragraph;
      }
    }

    final measureWidth = width * 0.99;
    final measureOffset = Offset(measureWidth, 1);

    for (var p in readPage.chapterContent.split('\n')) {
      while (true) {
        tp.text = TextSpan(text: p, style: style);
        tp.layout(maxWidth: measureWidth);
        final textCount = tp.getPositionForOffset(measureOffset).offset;
        if (textCount <= 0) {
          final forceEnd = p.isEmpty
              ? 0
              : (p.length > 1 &&
                      p.codeUnitAt(0) >= 0xD800 &&
                      p.codeUnitAt(0) <= 0xDBFF
                  ? 2
                  : 1)
                  .clamp(1, p.length);
          final text = p.substring(0, forceEnd);
          final isEnd = p.length == forceEnd;
          lines.add(TextLine(
            text,
            top: top,
            height: lineBoxH,
            targetWidth: width,
            isLastLine: isEnd,
            isParagraphEnd: isEnd,
          ));
          top += lineBoxH;
          if (isEnd) {
            newParagraph();
            break;
          }
          p = p.substring(forceEnd);
          if (top > height2) newPage();
          continue;
        }
        final text = p.substring(0, textCount);
        tp.text = TextSpan(text: text, style: style);
        tp.layout();
        final measured = tp.width;
        final isEnd = p.length == textCount;
        final n = text.runes.length;
        final nearlyFull = measured > width2 && measured > fontSize * 0.5;
        final doJustify = !isEnd && nearlyFull && n > 1;
        final h = tp.height > 0 ? tp.height : lineBoxH;
        lines.add(TextLine(
          text,
          top: top,
          height: h,
          targetWidth: width,
          justify: doJustify,
          isLastLine: isEnd,
          isParagraphEnd: isEnd,
        ));
        top += h;
        if (isEnd) {
          newParagraph();
          break;
        } else {
          p = p.substring(textCount);
          if (top > height2) newPage();
        }
      }
    }
    if (lines.isNotEmpty) {
      newPage();
    }
    if (pages.isEmpty) {
      pages.add(const TextPage([], 0));
    }
    return pages;
  }
}
