import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_source.dart';
import 'package:dashboard/features/reading/alexandria/zlib_book.dart';
import 'package:flutter/material.dart';

/// Ported `LittleBookCard`: cover, title, publisher, authors and metadata, plus
/// open/share actions that hand the composed site URL back to the page.
class ZlibBookCard extends StatelessWidget {
  const ZlibBookCard({
    required this.book,
    required this.onOpen,
    required this.onShare,
    super.key,
  });

  final ZlibBook book;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  /// The source swapped the "cover not exists" marker for a fallback image.
  String get coverUrl => book.imageUrl == AlexandriaSource.missingCoverMarker
      ? AlexandriaSource.missingCoverImage
      : book.imageUrl;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              height: 108,
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: Colors.black12),
                errorWidget: (_, _, _) => const Icon(Icons.menu_book_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (book.hasPublisher) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.publisher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (book.authors.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final author in book.authors)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              author,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${book.year} · ${book.language} · ${book.file}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('打开'),
                      ),
                      TextButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('分享'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
