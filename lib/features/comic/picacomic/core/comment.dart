/// Ports PicaComic's `Comment` model from `lib/comic_source/comic_source.dart`.
class Comment {
  final String userName;
  final String? avatar;
  final String content;
  final String? time;
  final int? replyCount;
  final String? id;

  const Comment(
    this.userName,
    this.avatar,
    this.content,
    this.time,
    this.replyCount,
    this.id,
  );
}
