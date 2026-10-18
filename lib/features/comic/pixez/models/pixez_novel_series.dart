import '../pixez_json.dart';

/// The series a novel belongs to (both fields are nullable in the API).
class PixezNovelSeries {
  const PixezNovelSeries({this.id, this.title});

  final int? id;
  final String? title;

  factory PixezNovelSeries.fromJson(Map<String, dynamic> json) {
    return PixezNovelSeries(
      id: pixezIntOrNull(json['id']),
      title: pixezStringOrNull(json['title']),
    );
  }
}
