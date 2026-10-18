/// Response of `like` / `favourite` (`haka_comic/lib/network/models.dart:558-568`).
class HakaActionResponse {
  const HakaActionResponse({required this.action});

  /// `'like'` or `'favourite'`.
  final String action;

  factory HakaActionResponse.fromJson(Map<String, dynamic> json) {
    return HakaActionResponse(action: json['action'] as String);
  }

  Map<String, dynamic> toJson() => {'action': action};
}
