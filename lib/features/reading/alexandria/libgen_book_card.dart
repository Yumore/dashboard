import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/reading/alexandria/libgen_book.dart';
import 'package:flutter/material.dart';

/// Ported `LibGenBookCard`: all thirteen parsed fields, with the download flow
/// reduced to opening the book's Library Genesis page (the source's own
/// fallback when it could not resolve a direct file link).
class LibGenBookCard extends StatelessWidget {
  const LibGenBookCard({
    required this.book,
    required this.onOpen,
    required this.onShare,
    super.key,
  });

  final LibGenBook book;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                  imageUrl: book.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: Colors.black12),
                  errorWidget: (_, _, _) => const Icon(Icons.book_outlined),
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
                      style: theme.textTheme.titleSmall,
                    ),
                    if (book.hasPublisher) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.publisher,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (book.series != 'not given') ...[
                      const SizedBox(height: 4),
                      Text(
                        '系列：${book.series}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${book.year} · ${book.language} · ${book.extension} ${book.size}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (book.isbn != 'not given')
                      Text(
                        'ISBN ${book.isbn}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onOpen,
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('下载页'),
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
}
