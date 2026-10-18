/// 每周必看 categories; the wire value is appended to `week/filter?...`.
///
/// Ports `WeekRecommendationType` from
/// PicaComic lib/network/jm_network/jm_network.dart:916.
enum JmWeekRecommendationType {
  korean('&type=hanman'),
  manga('&type=manga'),
  another('&type=another');

  const JmWeekRecommendationType(this.value);

  final String value;

  @override
  String toString() => value;
}
