import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_episode_page.dart';
import 'package:dashboard/features/anime/anime_show_details_page.dart';
import 'package:flutter/material.dart';

class AnimeShowDetailsPageState extends State<AnimeShowDetailsPage> {
  bool _favorite = false;
  bool _ready = false;
  bool _saving = false;
  bool _reversed = false;
  Set<String> _watched = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final favorites = await widget.favorites.load();
      final watched = await widget.history.watchedUrls();
      if (!mounted) return;
      setState(() {
        _favorite = favorites.any((show) => show.url == widget.show.url);
        _watched = watched;
        _ready = true;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _saving = true);
    try {
      await widget.favorites.toggle(widget.show);
      await _restore();
      await widget.onChanged();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _play(AnimeEpisode episode) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeEpisodePage(url: episode.url),
      ),
    );
    if (mounted) await _restore();
  }

  @override
  Widget build(BuildContext context) {
    final show = widget.show;
    final episodes = _reversed ? show.episodes.reversed : show.episodes;
    return Scaffold(
      appBar: AppBar(
        title: Text(show.title),
        actions: [
          IconButton(
            onPressed: !_ready || _saving ? null : _toggleFavorite,
            icon: Icon(_favorite ? Icons.star : Icons.star_border),
            tooltip: _favorite ? '取消收藏' : '收藏动漫',
          ),
        ],
      ),
      body: ListView(
        children: [
          if (_error != null)
            ListTile(
              title: Text('本地记录读取失败：$_error'),
              trailing: TextButton(
                onPressed: _restore,
                child: const Text('重试'),
              ),
            ),
          if (show.image != null && show.image!.hasScheme)
            Image.network(
              show.image.toString(),
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(height: 12),
            ),
          if (show.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(show.description),
            ),
          if (show.genres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(show.genres.join(' · ')),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _reversed = !_reversed),
              icon: const Icon(Icons.sort),
              label: Text(_reversed ? '恢复剧集顺序' : '倒序排列'),
            ),
          ),
          for (final episode in episodes)
            ListTile(
              title: Text(episode.title),
              leading: _watched.contains(episode.url.toString())
                  ? const Icon(Icons.check_circle_outline)
                  : null,
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _play(episode),
            ),
        ],
      ),
    );
  }
}
