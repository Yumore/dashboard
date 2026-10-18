import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';

/// A single styled text run of post content.
class TsdmTextRun {
  const TsdmTextRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.lineThrough = false,
    this.colorValue,
    this.backgroundColorValue,
    this.fontSizeValue,
    this.href,
  });

  /// Text content.
  final String text;

  /// Bold style.
  final bool bold;

  /// Italic style.
  final bool italic;

  /// Underlined style.
  final bool underline;

  /// Struck through style.
  final bool lineThrough;

  /// Parsed ARGB color value, null when no css color applies.
  final int? colorValue;

  /// Parsed ARGB background color value, null when not set.
  final int? backgroundColorValue;

  /// Font size in logical pixels, null when unset.
  final double? fontSizeValue;

  /// Link target, null when this run is not a link.
  final String? href;

  /// Whether this run is a link.
  bool get isLink => href != null;
}

/// An inline item of a post content line: either text or an image.
sealed class TsdmInlineItem {
  const TsdmInlineItem();
}

/// A text run item.
final class TsdmTextItem extends TsdmInlineItem {
  const TsdmTextItem(this.run);

  /// The text run.
  final TsdmTextRun run;
}

/// An inline image item.
final class TsdmImageItem extends TsdmInlineItem {
  const TsdmImageItem(this.image);

  /// The image.
  final TsdmImage image;
}

/// A parsed image of a post.
class TsdmImage {
  const TsdmImage({
    required this.url,
    this.alt,
    this.width,
    this.height,
    this.href,
  });

  /// Image url, host prefixed.
  final String url;

  /// Alt text.
  final String? alt;

  /// Optional css width.
  final double? width;

  /// Optional css height.
  final double? height;

  /// Link wrapping the image, if any.
  final String? href;
}

/// A quoted area of a post.
class TsdmQuote {
  const TsdmQuote({required this.author, required this.children});

  /// Name of the quoted author, may be null when the quote header is absent.
  final TsdmUser? author;

  /// Quoted content.
  final List<TsdmContentNode> children;
}

/// A collapsible (spoiler) area of a post.
class TsdmSpoiler {
  const TsdmSpoiler({required this.title, required this.children});

  /// Spoiler title text.
  final String title;

  /// Hidden content.
  final List<TsdmContentNode> children;
}

/// A code block of a post.
class TsdmCodeBlock {
  const TsdmCodeBlock(this.text);

  /// Code text, line breaks preserved.
  final String text;
}

/// A parsed node of the post content tree.
sealed class TsdmContentNode {
  const TsdmContentNode();
}

/// A line (paragraph) of inline items.
final class TsdmLineNode extends TsdmContentNode {
  const TsdmLineNode(this.items, {this.indent = 0});

  /// Inline items of this line.
  final List<TsdmInlineItem> items;

  /// Nesting depth, used to indent list items and quotes.
  final int indent;
}

/// A block quote node.
final class TsdmQuoteNode extends TsdmContentNode {
  const TsdmQuoteNode(this.quote);

  /// The quote.
  final TsdmQuote quote;
}

/// A spoiler node.
final class TsdmSpoilerNode extends TsdmContentNode {
  const TsdmSpoilerNode(this.spoiler);

  /// The spoiler.
  final TsdmSpoiler spoiler;
}

/// A code block node.
final class TsdmCodeNode extends TsdmContentNode {
  const TsdmCodeNode(this.code);

  /// The code block.
  final TsdmCodeBlock code;
}

/// A block level image node.
final class TsdmImageNode extends TsdmContentNode {
  const TsdmImageNode(this.image);

  /// The image.
  final TsdmImage image;
}
