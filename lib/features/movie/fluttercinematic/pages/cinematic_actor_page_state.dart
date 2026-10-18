import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_routes.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_actor_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_media_list.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_media_list_item.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicActorPage].
class CinematicActorPageState extends State<CinematicActorPage> {
  late final CinematicApi _api;

  /// `discover/movie` is paged, so the movies tab uses the shared list widget.
  late final CinematicPagingController _movieController;

  List<CinematicMediaItem> _shows = const <CinematicMediaItem>[];
  Object? _showsError;
  bool _showsLoading = true;

  List<CinematicMediaItem> get shows => List.unmodifiable(_shows);
  bool get showsLoading => _showsLoading;
  Object? get showsError => _showsError;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? CinematicApi();
    _movieController = CinematicPagingController(
      // `discover/movie?with_cast=` returns one page; the source never paged
      // it, and `pageSize` above TMDb's 20 stops the controller after the
      // first short response.
      pageSize: 1000,
      fetchPage: (_) => _api.getMoviesForActor(widget.actorId),
    );
    _loadShows();
  }

  @override
  void dispose() {
    _movieController.dispose();
    super.dispose();
  }

  Future<void> _loadShows() async {
    setState(() {
      _showsLoading = true;
      _showsError = null;
    });
    try {
      final shows = await _api.getShowsForActor(widget.actorId);
      if (!mounted) return;
      setState(() {
        _shows = shows;
        _showsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _showsError = error;
        _showsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CinematicMediaList(
              controller: _movieController,
              onItemTap: (item) =>
                  Navigator.of(context).push(CinematicRoutes.mediaDetail(item)),
            ),
            _buildShows(),
          ],
        ),
      ),
    );
  }

  Widget _buildShows() {
    if (_showsLoading) return const Center(child: CircularProgressIndicator());
    if (_showsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Something went wrong'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _loadShows, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_shows.isEmpty) {
      return const Center(child: Text('No TV credits'));
    }
    return ListView.builder(
      itemCount: _shows.length,
      itemBuilder: (context, index) {
        final show = _shows[index];
        return CinematicMediaListItem(
          item: show,
          onTap: (item) =>
              Navigator.of(context).push(CinematicRoutes.mediaDetail(item)),
        );
      },
    );
  }
}
