import 'package:dashboard/features/movie/youtubedl/youtubedl_search_result.dart';
import 'package:flutter/material.dart';

/// One YouTube search result row.
class YoutubeDlSearchTile extends StatelessWidget {
  const YoutubeDlSearchTile({
    super.key,
    required this.result,
    required this.onTap,
    this.busy = false,
  });

  final YoutubeDlSearchResult result;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 96,
          height: 54,
          child: result.thumbnail.isEmpty
              ? Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.movie_outlined),
                )
              : Image.network(
                  result.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.movie_outlined),
                  ),
                ),
        ),
      ),
      title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${result.author} · ${result.durationLabel}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: busy ? null : onTap,
    );
  }
}
