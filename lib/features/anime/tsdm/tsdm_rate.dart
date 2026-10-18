import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_single_rate.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Rate records of a post.
///
/// Ported from `tsdm_client/lib/shared/models/rate.dart`
/// (`Rate.fromRateLogNode`).
class TsdmRate {
  const TsdmRate({
    required this.userCount,
    required this.detailUrl,
    required this.attrList,
    required this.records,
    required this.rateStatus,
  });

  /// Count of users who rated.
  final int? userCount;

  /// Url containing the rate detail info.
  final String? detailUrl;

  /// Rated attribute names, used as column headers.
  final List<String> attrList;

  /// Rate records.
  final List<TsdmSingleRate> records;

  /// Total rate status text.
  final String? rateStatus;

  /// Build a rate from a `<dl id="ratelog_xxx" class="rate">` node.
  ///
  /// Returns null when any required part is missing, as the source does.
  static TsdmRate? fromRateLogNode(dom.Element? element) {
    if (element == null) {
      return null;
    }

    final rateHeaders = element.qAll('table > tbody:nth-child(1) > tr > th');
    if (rateHeaders.length < 2) {
      return null;
    }

    final infoNode = rateHeaders.firstOrNull?.q('a');
    final userCount = infoNode?.q('span.xi1')?.firstEndDeepText()?.parseToInt();
    if (userCount == null) {
      return null;
    }

    final detailUrl = infoNode?.firstHref();
    if (detailUrl == null) {
      return null;
    }

    final attrList = rateHeaders
        .skip(1)
        .map((e) => e.q('i')?.firstEndDeepText()?.trim())
        .whereType<String>()
        .toList();
    if (attrList.isEmpty) {
      return null;
    }

    final records = element
        .qAll('table > tbody.ratl_l > tr')
        .map(_parseSingleRate)
        .whereType<TsdmSingleRate>()
        .toList();
    if (records.isEmpty) {
      return null;
    }

    final rateStatus = element
        .q('p.ratc')
        ?.qAll('span')
        .map((e) => e.firstEndDeepText())
        .whereType<String>()
        .toList()
        .join(' ');
    if (rateStatus == null) {
      return null;
    }

    return TsdmRate(
      userCount: userCount,
      detailUrl: detailUrl,
      attrList: attrList,
      records: records,
      rateStatus: rateStatus,
    );
  }

  /// Parse a single rate record from a `<tr id="xxx">` node.
  static TsdmSingleRate? _parseSingleRate(dom.Element element) {
    final tdList = element.qAll('td');
    if (tdList.length < 2) {
      return null;
    }

    final userNode = tdList.firstOrNull;
    final url = userNode?.q('a:nth-child(1)')?.firstHref();
    final name = userNode?.q('a:nth-child(2)')?.firstEndDeepText();
    final avatarUrl = userNode?.q('a:nth-child(1) > img')?.imageUrl();
    final attrValueList = tdList
        .skip(1)
        .map((e) => e.firstEndDeepText()?.trim() ?? '')
        .toList();

    if (url == null || name == null) {
      return null;
    }

    return TsdmSingleRate(
      user: TsdmUser(name: name, url: url, avatarUrl: avatarUrl),
      attrValueList: attrValueList,
    );
  }
}
