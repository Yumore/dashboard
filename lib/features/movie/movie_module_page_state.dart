import 'package:dashboard/features/movie/movie_details_page.dart';
import 'package:dashboard/features/movie/movie_endpoint_store.dart';
import 'package:dashboard/features/movie/movie_favorites_store.dart';
import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:dashboard/features/movie/movie_source.dart';
import 'package:dashboard/features/short_video/short_video_demo_page.dart';
import 'package:flutter/material.dart';

class MovieModulePageState extends State<MovieModulePage> {
  final _endpointInput = TextEditingController();
  final _searchInput = TextEditingController();
  final _endpointStore = MovieEndpointStore();
  final _favoritesStore = MovieFavoritesStore();
  MovieSource? _source;
  Future<List<MovieItem>>? _results;
  List<MovieItem> _favorites = const [];
  String _classify = '电影';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final endpoint = await _endpointStore.load();
    final favorites = await _favoritesStore.load();
    if (!mounted) return;
    _endpointInput.text = endpoint ?? '';
    setState(() => _favorites = favorites);
    if (endpoint != null) _connect();
  }

  Future<void> _connect() async {
    final endpoint = Uri.tryParse(_endpointInput.text.trim());
    if (endpoint == null ||
        !<String>['http', 'https'].contains(endpoint.scheme)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入 HTTP/HTTPS 影视服务地址')));
      return;
    }
    _source?.dispose();
    _source = MovieSource(endpoint);
    await _endpointStore.save(endpoint.toString());
    if (mounted) setState(() => _results = _source!.recommendations(_classify));
  }

  void _search() {
    final query = _searchInput.text.trim();
    if (query.isEmpty || _source == null) return;
    setState(() => _results = _source!.search(query));
  }

  Future<void> _open(MovieItem item) async {
    final endpoint =
        item.serviceEndpoint ?? Uri.tryParse(_endpointInput.text.trim());
    final detailsSource =
        endpoint != null && ['http', 'https'].contains(endpoint.scheme)
        ? MovieSource(endpoint)
        : null;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MovieDetailsPage(
            movie: item,
            loadEpisodes: detailsSource == null
                ? null
                : () => detailsSource.episodes(item.id),
            onFavorite: () async {
              await _favoritesStore.toggle(item);
              final favorites = await _favoritesStore.load();
              if (mounted) setState(() => _favorites = favorites);
            },
          ),
        ),
      );
    } finally {
      detailsSource?.dispose();
    }
  }

  Widget _list(List<MovieItem> items) {
    if (items.isEmpty) return const Center(child: Text('暂无影视内容'));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: item.poster == null || !item.poster!.hasScheme
              ? const Icon(Icons.movie_outlined)
              : Image.network(
                  item.poster.toString(),
                  width: 48,
                  errorBuilder: (_, _, _) => const Icon(Icons.movie_outlined),
                ),
          title: Text(item.title),
          subtitle: Text(item.category),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(item),
        );
      },
    );
  }

  @override
  void dispose() {
    _source?.dispose();
    _endpointInput.dispose();
    _searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('影视'),
          actions: [
            IconButton(
              tooltip: '本地短视频演示',
              icon: const Icon(Icons.video_library_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ShortVideoDemoPage(),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '发现'),
              Tab(text: '片单'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _endpointInput,
                    decoration: InputDecoration(
                      labelText: '影视服务地址',
                      hintText: 'https://your-server.example',
                      suffixIcon: IconButton(
                        onPressed: _connect,
                        icon: const Icon(Icons.link),
                      ),
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                ),
                if (_source != null)
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _classify,
                        items: ['电影', '电视剧', '动漫', '综艺']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _classify = value;
                            _results = _source!.recommendations(value);
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchInput,
                          decoration: InputDecoration(
                            labelText: '搜索影片',
                            suffixIcon: IconButton(
                              onPressed: _search,
                              icon: const Icon(Icons.search),
                            ),
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                Expanded(
                  child: _results == null
                      ? const Center(child: Text('原影视工程依赖专用后端，请填写可访问的服务地址。'))
                      : FutureBuilder<List<MovieItem>>(
                          future: _results,
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Center(
                                child: Text('加载失败：${snapshot.error}'),
                              );
                            if (!snapshot.hasData)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            return _list(snapshot.data!);
                          },
                        ),
                ),
              ],
            ),
            _list(_favorites),
          ],
        ),
      ),
    );
  }
}
