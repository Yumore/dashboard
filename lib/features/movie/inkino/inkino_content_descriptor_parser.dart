import 'package:dashboard/features/movie/inkino/inkino_content_descriptor.dart';
import 'package:dashboard/features/movie/inkino/inkino_image_rewriter.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Maps the `<ContentDescriptors>` block (age-advice icons) of an event/show.
class InKinoContentDescriptorParser {
  const InKinoContentDescriptorParser._();

  /// [roots] mirrors the source signature: the `<ContentDescriptors>` wrapper
  /// is optional, so the first wrapper (if present) is the block to read.
  /// Everything below it is collected rather than just the first descriptor —
  /// films routinely carry several (Violence, Disturbing, ...).
  static List<InKinoContentDescriptor> parseRoots(List<InKinoXmlNode> roots) {
    if (roots.isEmpty) return const [];
    return parseBlock(roots.first);
  }

  static List<InKinoContentDescriptor> parseBlock(InKinoXmlNode block) {
    return InKinoXml.children(block, 'ContentDescriptor')
        .map(
          (node) => InKinoContentDescriptor(
            name: InKinoXml.childText(node, 'Name') ?? '',
            imageUrl: InKinoImageRewriter.rewrite(
              InKinoXml.childText(node, 'ImageURL'),
            ),
          ),
        )
        .toList();
  }
}
