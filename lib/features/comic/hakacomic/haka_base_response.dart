/// Envelope shared by every picacomic response
/// (`haka_comic/lib/network/models.dart:10-31`).
class HakaBaseResponse<T> {
  const HakaBaseResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;

  final String message;

  final T data;

  factory HakaBaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return HakaBaseResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {'code': code, 'message': message, 'data': toJsonT(data)};
  }
}
