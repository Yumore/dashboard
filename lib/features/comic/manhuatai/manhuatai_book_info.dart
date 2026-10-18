import 'package:dashboard/features/comic/manhuatai/manhuatai_book_info_data.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Wrapper for the `getbookinfo_sys` album response.
///
/// Source: `lib/models/get_book_info_by_id.dart` → `GetBookInfoById`.
class ManhuataiBookInfo {
  const ManhuataiBookInfo({
    required this.data,
    required this.status,
    required this.message,
  });

  final ManhuataiBookInfoData data;
  final int status;
  final String message;

  static const ManhuataiBookInfo empty = ManhuataiBookInfo(
    data: ManhuataiBookInfoData.empty,
    status: 0,
    message: '',
  );

  factory ManhuataiBookInfo.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBookInfo(
      data: ManhuataiBookInfoData.fromJson(
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
