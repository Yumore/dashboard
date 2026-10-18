import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';

/// A group of forums shown on the forum home page.
///
/// Ported from `tsdm_client/lib/shared/models/forum_group.dart`.
class TsdmForumGroup {
  const TsdmForumGroup({
    required this.name,
    required this.url,
    required this.forumList,
  });

  /// Forum group name.
  final String name;

  /// Forum group url.
  final String url;

  /// All sub forums in this group.
  final List<TsdmForum> forumList;
}
