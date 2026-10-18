import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// An entry of the thread operation log.
///
/// Ported from `tsdm_client/lib/features/thread/v1/models/operation_log_item.dart`.
class TsdmOperationLogItem {
  const TsdmOperationLogItem({
    required this.username,
    required this.action,
    required this.time,
    this.duration,
  });

  /// Moderator who performed the action.
  final String username;

  /// Action description.
  final String action;

  /// Time of the action.
  final DateTime time;

  /// Optional duration text.
  final String? duration;

  /// Build from a `<tr>` node, null when the row is not an operation entry.
  static TsdmOperationLogItem? fromTr(dom.Element element) {
    final tds = element.qAll('td');
    if (tds.length != 4) {
      return null;
    }
    final username = element.q('a')?.text;
    final time = tds[1].dateTime();
    final action = tds[2].text;
    final durationText = tds[3].text;
    if (username == null || time == null) {
      return null;
    }
    return TsdmOperationLogItem(
      username: username,
      action: action,
      time: time,
      duration: durationText.isEmpty ? null : durationText,
    );
  }
}
