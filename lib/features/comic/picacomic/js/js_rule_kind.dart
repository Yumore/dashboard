/// The rule entry points a user JS source may implement.
///
/// Ports the method names PicaComic's `ComicSourceParser` probes for with
/// `_checkExists(...)` calls against the QuickJS instance.
enum JsRuleKind {
  init('init'),
  login('login'),
  logout('logout'),
  loadComic('loadComic'),
  loadComicPages('loadComicPages'),
  getImageLoadingConfig('getImageLoadingConfig'),
  getThumbnailLoadingConfig('getThumbnailLoadingConfig'),
  search('search'),
  category('category'),
  explore('explore'),
  favorites('favorites'),
  loadComments('loadComments'),
  sendComment('sendComment');

  /// The property name as written in the JS class body.
  final String scriptName;

  const JsRuleKind(this.scriptName);
}
