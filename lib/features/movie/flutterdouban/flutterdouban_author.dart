import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// `author` on reviews and short comments.
class FlutterDouBanAuthor {
  const FlutterDouBanAuthor({
    this.id = '',
    this.uid = '',
    this.name = '',
    this.avatar = '',
    this.signature = '',
    this.alt = '',
  });

  factory FlutterDouBanAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FlutterDouBanAuthor();
    return FlutterDouBanAuthor(
      id: FlutterDouBanJson.asString(json['id']).trim(),
      uid: FlutterDouBanJson.asString(json['uid']).trim(),
      name: FlutterDouBanJson.asString(json['name']).trim(),
      avatar: FlutterDouBanJson.asString(json['avatar']).trim(),
      signature: FlutterDouBanJson.asString(json['signature']).trim(),
      alt: FlutterDouBanJson.asString(json['alt']).trim(),
    );
  }

  final String id;
  final String uid;
  final String name;
  final String avatar;
  final String signature;
  final String alt;

  String? get avatarUrl => FlutterDouBanImage.resolve(avatar);
}
