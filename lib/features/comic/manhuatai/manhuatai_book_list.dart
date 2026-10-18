import 'package:dashboard/features/comic/manhuatai/manhuatai_book_section.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Wrapper returned by the recommendation / position endpoints.
///
/// `status != 0` means "no data"; the source replaced the whole payload with an
/// empty object in that case, which is preserved by [empty].
///
/// Source: `lib/models/book_list.dart` → `BookList`.
class ManhuataiBookList {
  const ManhuataiBookList({
    required this.data,
    required this.status,
    required this.message,
  });

  final ManhuataiBookSection data;
  final int status;
  final String message;

  static const ManhuataiBookList empty = ManhuataiBookList(
    data: ManhuataiBookSection.empty,
    status: 0,
    message: '',
  );

  factory ManhuataiBookList.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBookList(
      data: ManhuataiBookSection.fromJson(
        ManhuataiJson.map(source['data']),
      ),
      status: ManhuataiJson.asInt(source['status']),
      message: ManhuataiJson.asString(source['message']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data.toJson(),
        'status': status,
        'message': message,
      };
}
