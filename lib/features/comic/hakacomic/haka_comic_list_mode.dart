/// Which backend endpoint a [HakaComicListController] pages through.
enum HakaComicListMode {
  /// `GET comics?c=<category>`.
  category,

  /// `GET users/favourite`.
  favourites,

  /// `POST comics/advanced-search`.
  search,
}
