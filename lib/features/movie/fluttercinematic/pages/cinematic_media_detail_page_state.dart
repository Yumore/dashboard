import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_date_format.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_genres.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_routes.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_media_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_actor_card.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_detail_row.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_favorite_button.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_poster_card.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_section_header.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_similar_media_list.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicMediaDetailPage]; loads `{type}/{id}`,
/// `{type}/{id}/credits`, `{type}/{id}/similar` and, for a show, `tv/{id}`'s
/// `seasons`.
class CinematicMediaDetailPageState extends State<CinematicMediaDetailPage> {
  late final CinematicApi _api;
  late final CinematicFavoritesStore _store;
  late final CinematicPagingController _similarController;

  Map<String, dynamic>? _details;
  List<CinematicActor> _cast = const <CinematicActor>[];
  List<CinematicTvSeason> _seasons = const <CinematicTvSeason>[];
  Object? _error;
  bool _isLoading = true;

  bool get _isMovie => widget.type == 'movie';

  /// Exposed for tests: the raw `{type}/{id}` payload that was mapped.
  Map<String, dynamic>? get details => _details;
  List<CinematicActor> get cast => List.unmodifiable(_cast);
  List<CinematicTvSeason> get seasons => List.unmodifiable(_seasons);
  bool get isLoading => _isLoading;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? CinematicApi();
    _store = widget.store ?? CinematicFavoritesStore();
    _store.load();
    _similarController = CinematicPagingController(
      fetchPage: (page) =>
          _api.getSimilarMedia(widget.id, type: widget.type, page: page),
    );
    _load();
  }

  @override
  void dispose() {
    _similarController.dispose();
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final details = await _api.getMediaDetails(widget.id, type: widget.type);
      final cast = await _api.getMediaCredits(widget.id, type: widget.type);
      final seasons = _isMovie
          ? const <CinematicTvSeason>[]
          : await _api.getShowSeasons(widget.id);
      if (!mounted) return;
      setState(() {
        _details = details;
        _cast = cast;
        _seasons = seasons;
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

  String get _title {
    final details = _details;
    if (details == null) return widget.title;
    return '${details[_isMovie ? 'title' : 'name'] ?? widget.title}';
  }

  String get _releaseDate =>
      '${_details?[_isMovie ? 'release_date' : 'first_air_date'] ?? ''}';

  /// The favourite row needs a [CinematicMediaItem]; the detail payload is
  /// mapped through the same model the search/home lists use.
  CinematicMediaItem? get _mediaItem {
    final details = _details;
    if (details == null) return null;
    return CinematicMediaItem.fromJson(
      details,
      type: _isMovie ? CinematicMediaType.movie : CinematicMediaType.show,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaItem = _mediaItem;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          if (mediaItem != null)
            CinematicFavoriteButton(store: _store, item: mediaItem),
        ],
      ),
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
    final details = _details ?? const <String, dynamic>{};
    final genres = _intList(details['genres'], 'id');
    return ListView(
      children: <Widget>[
        CinematicImage(
          _imageUrl('${details['backdrop_path'] ?? ''}'),
          height: 220,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CinematicImage(
                _imageUrl('${details['poster_path'] ?? ''}'),
                width: 110,
                height: 165,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_title, style: Theme.of(context).textTheme.titleLarge),
                    if ('${details['tagline'] ?? ''}'.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${details['tagline']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (details['vote_average'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Rating: ${details['vote_average']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const CinematicSectionHeader('Overview'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${details['overview'] ?? ''}'),
        ),
        const CinematicSectionHeader('Details'),
        CinematicDetailRow(
          title: 'Status',
          value: '${details['status'] ?? ''}',
        ),
        if (CinematicGenres.label(genres).isNotEmpty)
          CinematicDetailRow(
            title: 'Genres',
            value: CinematicGenres.label(genres),
          ),
        if (_isMovie)
          CinematicDetailRow(
            title: 'Runtime',
            value: '${details['runtime'] ?? 0} min',
          )
        else ...<Widget>[
          CinematicDetailRow(
            title: 'Seasons',
            value: '${details['number_of_seasons'] ?? 0}',
          ),
          CinematicDetailRow(
            title: 'Episodes',
            value: '${details['number_of_episodes'] ?? 0}',
          ),
        ],
        CinematicDetailRow(
          title: _isMovie ? 'Release date' : 'First air date',
          value: CinematicDateFormat.format(_releaseDate),
        ),
        CinematicDetailRow(title: 'Budget', value: '${details['budget'] ?? 0}'),
        CinematicDetailRow(
          title: 'Revenue',
          value: '${details['revenue'] ?? 0}',
        ),
        if (_isMovie)
          CinematicDetailRow(
            title: 'Original title',
            value: '${details['original_title'] ?? ''}',
          )
        else ...<Widget>[
          if (_createdByLabel(details).isNotEmpty)
            CinematicDetailRow(
              title: 'Created by',
              value: _createdByLabel(details),
            ),
          if (_networksLabel(details).isNotEmpty)
            CinematicDetailRow(
              title: 'Networks',
              value: _networksLabel(details),
            ),
        ],
        if ('${details['homepage'] ?? ''}'.isNotEmpty)
          CinematicDetailRow(
            title: 'Homepage',
            value: '${details['homepage']}',
          ),
        if ('${details['imdb_id'] ?? ''}'.isNotEmpty)
          CinematicDetailRow(
            title: 'IMDb',
            value: '${CinematicConstants.imdbTitleBase}${details['imdb_id']}/',
          ),
        if (_cast.isNotEmpty) ...<Widget>[
          const CinematicSectionHeader('Cast'),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _cast.length,
              itemBuilder: (context, index) {
                final actor = _cast[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CinematicActorCard(
                    actor: actor,
                    onTap: (selected) => Navigator.of(
                      context,
                    ).push(CinematicRoutes.actor(selected)),
                  ),
                );
              },
            ),
          ),
        ],
        if (!_isMovie && _seasons.isNotEmpty) ...<Widget>[
          const CinematicSectionHeader('Seasons'),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _seasons.length,
              itemBuilder: (context, index) {
                final season = _seasons[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CinematicPosterCard.season(
                    season: season,
                    onTap: () => Navigator.of(context).push(
                      CinematicRoutes.seasonDetail(
                        showId: widget.id,
                        season: season,
                        showTitle: _title,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        CinematicSimilarMediaList(
          controller: _similarController,
          title: 'Similar',
          onItemTap: (item) =>
              Navigator.of(context).push(CinematicRoutes.mediaDetail(item)),
        ),
      ],
    );
  }

  String _imageUrl(String path) => CinematicImageUrl.medium(path);

  static String _createdByLabel(Map<String, dynamic> details) =>
      CinematicGenres.joinKey(_rows(details['created_by']), 'name');

  static String _networksLabel(Map<String, dynamic> details) =>
      CinematicGenres.joinKey(_rows(details['networks']), 'name');

  static List<dynamic> _rows(Object? value) =>
      value is List ? value : const <dynamic>[];

  static List<int> _intList(Object? value, String key) {
    if (value is! List) return const <int>[];
    return value
        .whereType<Map>()
        .map((row) => row[key])
        .whereType<num>()
        .map((number) => number.toInt())
        .toList();
  }
}
