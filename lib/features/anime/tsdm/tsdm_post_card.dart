import 'package:dashboard/features/anime/tsdm/tsdm_plain_text_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post.dart';
import 'package:flutter/material.dart';

/// Card showing a single post of a thread.
///
/// Ported from the post body rendering of
/// `tsdm_client/lib/widgets/card/post_card/post_card.dart`; the bbcode widget
/// tree of the source is replaced by the plain text extracted from the parsed
/// html, which keeps the parsed [TsdmPost] fields authoritative.
class TsdmPostCard extends StatelessWidget {
  /// Create a post card for [post].
  const TsdmPostCard({required this.post, this.onTap, super.key});

  /// Post to show.
  final TsdmPost post;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (post.author.avatarUrl != null)
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(post.author.avatarUrl!),
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (post.userBriefProfile?.userGroup != null)
                          Text(
                            post.userBriefProfile?.userGroup ?? '',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (post.postFloor != null) Text('#${post.postFloor}'),
                ],
              ),
              if (post.publishTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${post.publishTime}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              if (post.postMedals != null && post.postMedals!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    children: [
                      for (final medal in post.postMedals!)
                        if (medal.alter.isNotEmpty)
                          Chip(label: Text(medal.alter)),
                    ],
                  ),
                ),
              if (post.locked.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    post.locked
                        .map((e) => e.lockedWithPoints ? '需要积分' : '需要购买')
                        .join('、'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(post.data.extractPlainText()),
              ),
              if (post.signature != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    post.signature!.extractPlainText(),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
