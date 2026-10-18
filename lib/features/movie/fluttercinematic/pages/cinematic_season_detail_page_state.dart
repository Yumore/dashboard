import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_episode.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_season_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_episode_card.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_section_header.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicSeasonDetailPage].
class CinematicSeasonDetailPageState extends State<CinematicSeasonDetailPage> {
  late final CinematicApi _api;
  List<CinematicEpisode> _episodes = const <CinematicEpisode>[];
  Object? _error;
  bool _isLoading = true;

  List<CinematicEpisode> get episodes => List.unmodifiable(_episodes);
  bool get isLoading => _isLoading;

  int get seasonNumber => widget.season.seasonNumber;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? CinematicApi();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final episodes = await _api.fetchEpisodes(widget.showId, seasonNumber);
      if (!mounted) return;
      setState(() {
        _episodes = episodes;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.season.getFormattedTitle())),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Something went wrong'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView(
      children: <Widget>[
        CinematicImage(
          CinematicImageUrl.large(widget.season.posterPath),
          height: 200,
          width: double.infinity,
        ),
        CinematicSectionHeader(widget.showTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${widget.season.name} • ${widget.season.episodeCount} episodes',
          ),
        ),
        if (widget.season.overview.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(widget.season.overview),
          ),
        const CinematicSectionHeader('Episodes'),
        for (final episode in _episodes) CinematicEpisodeCard(episode: episode),
      ],
    );
  }
}
