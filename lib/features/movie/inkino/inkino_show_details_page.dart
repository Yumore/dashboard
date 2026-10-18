import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Film detail for one selected showtime.
///
/// The detail data comes from the `<Show>` element itself: inKino's API layer
/// had no per-event detail call — `/xml/Schedule` and `/xml/Events` were the
/// only endpoints — so no extra request is issued here.
class InKinoShowDetailsPage extends StatelessWidget {
  const InKinoShowDetailsPage({required this.show, super.key});

  final InKinoShow show;

  Future<void> _openShowPage() async {
    final uri = Uri.tryParse(show.url);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final poster = show.images.anyPortrait ?? show.images.anyAvailable;
    return Scaffold(
      appBar: AppBar(
        title: Text(show.title),
        actions: [
          if (show.url.isNotEmpty)
            IconButton(
              tooltip: '在 Finnkino 打开购票页',
              onPressed: _openShowPage,
              icon: const Icon(Icons.open_in_new),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (poster != null)
            CachedNetworkImage(
              imageUrl: poster,
              height: 220,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const SizedBox(height: 0),
              placeholder: (_, _) => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  show.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (show.originalTitle.isNotEmpty &&
                    show.originalTitle != show.title) ...[
                  const SizedBox(height: 4),
                  Text(
                    show.originalTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final genre in show.genreList)
                      Chip(label: Text(genre)),
                  ],
                ),
                const SizedBox(height: 16),
                _row('影院', show.theaterName.isEmpty ? '未指定' : show.theaterName),
                _row('影厅', show.auditorium.isEmpty ? '未指定' : show.auditorium),
                _row('场次', '${show.startsAtLabel} – ${show.endsAtLabel}'),
                if (show.lengthInMinutesValue != null)
                  _row('时长', '${show.lengthInMinutesValue} 分钟'),
                if (show.productionYear != null)
                  _row('年份', show.productionYear!),
                if (show.presentationMethod != null)
                  _row('放映格式', show.presentationMethod!),
                if (show.hasAgeRating) _row('分级', show.ageRating!),
                _row('场次 ID', show.id),
                _row('影片 ID', show.eventId),
                if (show.images.landscapeLarge != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '剧照',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: show.images.landscapeLarge!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const SizedBox(height: 0),
                      placeholder: (_, _) => const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
