import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// A subject plus the rank/box-office note a tab wants to show.
///
/// Keeps the browse tabs uniform: the plain list endpoints leave [rank] and
/// [note] null, while `weekly` fills `rank` + `delta` and `us_box` fills
/// `rank` + `box`.
class FlutterDouBanSubjectRow {
  const FlutterDouBanSubjectRow({
    required this.subject,
    this.rank,
    this.note,
    this.rankDelta,
  });

  FlutterDouBanSubjectRow.fromSubject(FlutterDouBanSubject subject)
    : this(subject: subject);

  final FlutterDouBanSubject subject;

  /// 1-based position, when the payload carries one.
  final int? rank;

  /// Free-form trailing note (`$12,345,678`).
  final String? note;

  /// Rank movement on the weekly chart (`↑10` / `↓3` / `—`).
  final String? rankDelta;

  String get id => subject.id;
  String get title => subject.title;

  String get rankLabel => rank == null ? '' : '$rank';
}
