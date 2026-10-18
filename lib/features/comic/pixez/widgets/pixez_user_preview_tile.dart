import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/pixez_user_preview.dart';

/// Row for one `/v1/search/user` result.
class PixezUserPreviewTile extends StatelessWidget {
  const PixezUserPreviewTile({
    required this.preview,
    this.onTap,
    super.key,
  });

  final PixezUserPreview preview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final user = preview.user;
    return ListTile(
      onTap: onTap,
      leading: ClipOval(
        child: CachedNetworkImage(
          imageUrl: user.avatarUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const ColoredBox(color: Colors.black12),
          errorWidget: (context, url, error) => const ColoredBox(
            color: Colors.black12,
            child: Icon(Icons.person_outline),
          ),
        ),
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '@${user.account} · 作品 ${preview.illusts.length} · 小说 ${preview.novels.length}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: preview.isMuted
          ? const Icon(Icons.volume_off_outlined, size: 18)
          : null,
    );
  }
}
