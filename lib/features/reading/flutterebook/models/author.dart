import 'package:dashboard/features/reading/flutterebook/models/id.dart';

/// FeedbooksFeed level author element of a Feedbooks atom feed.
class FeedbooksAuthor {
  FeedbooksAuthor({this.name, this.uri, this.email});

  FeedbooksAuthor.fromJson(Map<String, dynamic> json) {
    name = json['name'] != null
        ? FeedbooksId.fromJson(json['name'] as Map<String, dynamic>)
        : null;
    uri = json['uri'] != null
        ? FeedbooksId.fromJson(json['uri'] as Map<String, dynamic>)
        : null;
    email = json['email'] != null
        ? FeedbooksId.fromJson(json['email'] as Map<String, dynamic>)
        : null;
  }

  FeedbooksId? name;
  FeedbooksId? uri;
  FeedbooksId? email;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (uri != null) {
      data['uri'] = uri!.toJson();
    }
    if (email != null) {
      data['email'] = email!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksAuthor(name: $name, uri: $uri, email: $email)';
  }
}
