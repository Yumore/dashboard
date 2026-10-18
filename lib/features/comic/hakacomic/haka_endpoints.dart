/// Paths of the picacomic schema, copied verbatim from
/// `haka_comic/lib/network/http.dart`.
class HakaEndpoints {
  const HakaEndpoints._();

  static const String categories = 'categories';

  static const String comics = 'comics';

  static const String favouriteComics = 'users/favourite';

  static const String hotSearchWords = 'keywords';

  static const String signIn = 'auth/sign-in';

  static const String profile = 'users/profile';

  static const String leaderboard = 'comics/leaderboard';

  static const String randomComics = 'comics/random';

  /// `comics/advanced-search?page=N` — the page is embedded in the path, so it
  /// takes part in the signature even though the verb is POST
  /// (`haka_comic/lib/network/http.dart:160-170`).
  static String searchComics(int page) => 'comics/advanced-search?page=$page';

  static String comicDetails(String id) => 'comics/$id';

  static String comicChapters(String id) => 'comics/$id/eps';

  static String comicRecommendation(String id) => 'comics/$id/recommendation';

  static String comicLike(String id) => 'comics/$id/like';

  static String comicFavourite(String id) => 'comics/$id/favourite';

  static String chapterImages(String id, int order) =>
      'comics/$id/order/$order/pages';

  static String comicComments(String id) => 'comics/$id/comments';
}
