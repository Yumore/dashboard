import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Checkin status of a post floor.
///
/// Ported from `tsdm_client/lib/widgets/card/post_card/checkin.dart`.
class TsdmPostCheckinStatus {
  const TsdmPostCheckinStatus({
    required this.feelingImage,
    required this.feelingName,
    required this.words,
    required this.statistics,
  });

  /// Url of the feeling image.
  final String feelingImage;

  /// Readable name of the feeling.
  final String feelingName;

  /// Checkin words.
  final String words;

  /// Checkin statistics.
  final String statistics;

  /// Build from a `div.qdsmile` node.
  static TsdmPostCheckinStatus? fromDiv(dom.Element element) {
    final feelingImage = element
        .q('li > table > tbody > tr > th:nth-child(1) > a > img')
        ?.imageUrl();
    final feelingName = element
        .q('li > table > tbody > tr > th:nth-child(2)')
        ?.firstEndDeepText();
    final words = element.q('li > div')?.firstEndDeepText();
    final statistics = element.q('li > p')?.firstEndDeepText();

    if (feelingImage == null ||
        feelingName == null ||
        words == null ||
        statistics == null) {
      return null;
    }

    return TsdmPostCheckinStatus(
      feelingImage: feelingImage,
      feelingName: feelingName,
      words: words,
      statistics: statistics,
    );
  }
}
