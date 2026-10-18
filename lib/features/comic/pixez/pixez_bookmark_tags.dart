/// Joins bookmark tags the way pixez `ApiClient.postLikeIllust` does.
///
/// The source keeps the first tag verbatim and trims every later tag, then
/// joins the list with single spaces into the `tags[]` form field. That quirk
/// is preserved so the request matches the client pixiv expects.
String? pixezJoinBookmarkTags(List<String> tags) {
  if (tags.isEmpty) return null;
  var result = tags.first;
  for (var i = 1; i < tags.length; i++) {
    result = '$result ${tags[i].trim()}';
  }
  return result;
}
