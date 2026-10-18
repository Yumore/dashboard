/// The two TMDb media kinds the MovieApp source browses.
enum MovieAppMediaKind {
  movie,
  tv;

  bool get isMovie => this == MovieAppMediaKind.movie;

  String get label => isMovie ? '电影' : '剧集';

  /// Path segment used by both the API (`movie/...`) and the TMDb website.
  String get webPath => isMovie ? 'movie' : 'tv';
}
