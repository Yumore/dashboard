import 'package:dashboard/features/reading/flutterebook/models/feed.dart';

/// Top level container handed to the repositories: the XML declaration plus the
/// `<feed>` element of a Feedbooks atom document.
class FeedbooksCategoryFeed {
  FeedbooksCategoryFeed({this.version, this.encoding, this.feed});

  FeedbooksCategoryFeed.fromJson(Map<String, dynamic> json) {
    version = json['version'] as String?;
    encoding = json['encoding'] as String?;
    feed = json['feed'] != null
        ? FeedbooksFeed.fromJson(json['feed'] as Map<String, dynamic>)
        : null;
  }

  String? version;
  String? encoding;
  FeedbooksFeed? feed;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['encoding'] = encoding;
    if (feed != null) {
      data['feed'] = feed!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'FeedbooksCategoryFeed(version: $version, encoding: $encoding, feed: $feed)';
  }
}
