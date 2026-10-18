import 'package:dashboard/features/movie/movieapp/movieapp_credits.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_details_page.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_genres.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_list_result.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie_detail.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_network_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_video.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieAppDetailsPageState extends State<MovieAppDetailsPage> {
  late Future<MovieAppMovieDetail> _detail;
  late Future<MovieAppCredits> _credits;
  late Future<List<MovieAppVideo>> _videos;
  late Future<MovieAppListResult> _similar;

  MovieAppMovie get _movie => widget.movie;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Requests are created here (and on retry), never in `build`.
  void _load() {
    _detail = widget.api.detailOf(_movie);
    _credits = widget.api.creditsOf(_movie);
    _videos = widget.api.videosOf(_movie);
    _similar = widget.api.similarOf(_movie);
  }

  Future<void> _openVideo(MovieAppVideo video) async {
    final uri = video.watchUri;
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openTmdb() async {
    await launchUrl(_movie.webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openSimilar(MovieAppMovie movie) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieAppDetailsPage(movie: movie, api: widget.api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_movie.displayTitle),
      actions: [
        IconButton(
          tooltip: '在 TMDb 打开',
          onPressed: _openTmdb,
          icon: const Icon(Icons.open_in_new),
        ),
      ],
    ),
    body: ListView(
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _movie.displayTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${_movie.kind.label} · ${_movie.year} · '
                '★${_movie.voteAverage.toStringAsFixed(1)}'
                '（${_movie.voteCount} 票）',
              ),
              const SizedBox(height: 8),
              _detailFacts(),
              const SizedBox(height: 12),
              _genreChips(),
              const SizedBox(height: 16),
              const Text(
                '剧情简介',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_movie.overview.isEmpty ? '暂无简介' : _movie.overview),
            ],
          ),
        ),
        _trailerSection(),
        _castSection(),
        _similarSection(),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _header() => SizedBox(
    height: 220,
    child: Stack(
      children: [
        Positioned.fill(child: MovieAppNetworkImage(_movie.backdropUrl)),
        Positioned(
          left: 16,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 90,
              height: 130,
              child: MovieAppNetworkImage(_movie.posterUrl),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _detailFacts() => FutureBuilder<MovieAppMovieDetail>(
    future: _detail,
    builder: (context, snapshot) {
      if (snapshot.hasError) return _inlineError(snapshot.error);
      final detail = snapshot.data;
      if (detail == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        );
      }
      final facts = <String>[
        if (detail.runtimeLabel.isNotEmpty) detail.runtimeLabel,
        if (detail.status.isNotEmpty) detail.status,
        if (detail.seasonCount != null) '${detail.seasonCount} 季',
        if (detail.episodeCount != null) '${detail.episodeCount} 集',
        if (detail.tagline.isNotEmpty) detail.tagline,
      ];
      if (facts.isEmpty) return const SizedBox.shrink();
      return Text(facts.join(' · '));
    },
  );

  Widget _genreChips() => FutureBuilder<MovieAppMovieDetail>(
    future: _detail,
    builder: (context, snapshot) {
      final names = <String>[
        for (final genre in snapshot.data?.genres ?? const []) genre.name,
      ];
      if (names.isEmpty) {
        names.addAll(
          _movie.genreIds
              .map(MovieAppGenres.name)
              .where((name) => name.isNotEmpty),
        );
      }
      if (names.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final name in names) Chip(label: Text(name))],
      );
    },
  );

  Widget _trailerSection() => _sectionShell(
    title: '预告片',
    child: FutureBuilder<List<MovieAppVideo>>(
      future: _videos,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _inlineError(snapshot.error);
        final videos = snapshot.data;
        if (videos == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final playable = videos
            .where((video) => video.watchUri != null)
            .toList();
        if (playable.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('暂无预告片。TMDb 不提供影片流地址。'),
          );
        }
        return Column(
          children: [
            for (final video in playable)
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(video.name.isEmpty ? '预告片' : video.name),
                subtitle: Text('${video.site} · ${video.type}'),
                onTap: () => _openVideo(video),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'TMDb 只提供 YouTube 预告片，没有可直接播放的影片流地址。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _castSection() => _sectionShell(
    title: '演员',
    child: SizedBox(
      height: 160,
      child: FutureBuilder<MovieAppCredits>(
        future: _credits,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _inlineError(snapshot.error);
          final credits = snapshot.data;
          if (credits == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (credits.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无演员信息'),
            );
          }
          final cast = credits.cast.take(20).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 100,
                        child: MovieAppNetworkImage(member.profileUrl),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      member.character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ),
  );

  Widget _similarSection() => _sectionShell(
    title: '相似影片',
    child: SizedBox(
      height: 200,
      child: FutureBuilder<MovieAppListResult>(
        future: _similar,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _inlineError(snapshot.error);
          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = result.results.take(10).toList();
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无相似影片'),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final movie = items[index];
              return GestureDetector(
                onTap: () => _openSimilar(movie),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 120,
                          height: 150,
                          child: MovieAppNetworkImage(movie.posterUrl),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );

  Widget _sectionShell({required String title, required Widget child}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          child,
        ],
      );

  Widget _inlineError(Object? error) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(child: Text('加载失败：${error ?? '未知错误'}')),
        TextButton(onPressed: () => setState(_load), child: const Text('重试')),
      ],
    ),
  );
}
