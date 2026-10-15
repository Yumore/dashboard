class AnimeCategory {
  const AnimeCategory(this.path, this.label, {this.directPlayback = false});

  final String path;
  final String label;
  final bool directPlayback;

  static const values = [
    AnimeCategory('/subbed-anime-list', '字幕番剧'),
    AnimeCategory('/dubbed-anime-list', '配音番剧'),
    AnimeCategory('/cartoon-list', '动画'),
    AnimeCategory('/movie-list', '动漫电影', directPlayback: true),
    AnimeCategory('/ova-list', 'OVA', directPlayback: true),
  ];
}
