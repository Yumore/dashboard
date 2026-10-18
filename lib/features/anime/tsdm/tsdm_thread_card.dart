import 'package:dashboard/features/anime/tsdm/tsdm_normal_thread.dart';
import 'package:flutter/material.dart';

/// A thread row of a forum list.
class TsdmThreadCard extends StatelessWidget {
  /// Create a thread card of [thread].
  const TsdmThreadCard({required this.thread, this.onTap, super.key});

  /// Thread to show.
  final TsdmNormalThread thread;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = thread.price;
    final privilege = thread.privilege;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thread.stateSet.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 2),
                      child: Icon(
                        thread.stateSet.first.icon,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      thread.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: thread.isRecentThread
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${thread.author.name} · ${_formatTime(thread.publishDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${thread.replyCount} / ${thread.viewCount}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (price != null ||
                  privilege != null ||
                  thread.threadType != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (thread.threadType != null)
                        Text('[${thread.threadType!.name}]'),
                      if (price != null) Text('售价 $price'),
                      if (privilege != null) Text('阅读权限 $privilege'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime? time) {
    if (time == null) {
      return '';
    }
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${time.year}-$month-$day $hour:$minute';
  }
}
