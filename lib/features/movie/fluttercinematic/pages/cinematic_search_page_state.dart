import 'dart:async';

import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_routes.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_search_result.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_search_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_search_result_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicSearchPage]; owns the 400ms debounce from the
/// source `SearchBar(onSearch: ...)` plus a generation guard.
class CinematicSearchPageState extends State<CinematicSearchPage> {
  static const Duration debounce = Duration(milliseconds: 400);

  late final CinematicApi _api;
  late final CinematicFavoritesStore _store;
  late final TextEditingController _textController;

  Timer? _timer;
  int _generation = 0;
  String _lastQuery = '';
  List<CinematicSearchResult> _results = const <CinematicSearchResult>[];
  bool _isLoading = false;
  Object? _error;

  List<CinematicSearchResult> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  Object? get error => _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? CinematicApi();
    _store = widget.store ?? CinematicFavoritesStore();
    _store.load();
    _textController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _scheduleSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _generation++;
    _textController.dispose();
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  void _onChanged(String value) => _scheduleSearch(value);

  void _scheduleSearch(String value) {
    _timer?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = const <CinematicSearchResult>[];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    _timer = Timer(debounce, () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;
    final generation = ++_generation;
    _lastQuery = query;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await _api.getSearchResults(query);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  /// The last query actually sent to `search/multi` (diagnostics only).
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('lastQuery', _lastQuery));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _textController,
              onChanged: _onChanged,
              onSubmitted: _search,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search movies, shows and people',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          if (_error != null)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Search failed'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return CinematicSearchResultCard(
                  result: result,
                  onTap: (selected) => Navigator.of(
                    context,
                  ).push(CinematicRoutes.searchResult(selected)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
