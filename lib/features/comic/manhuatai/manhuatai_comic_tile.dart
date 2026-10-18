import 'package:dashboard/features/comic/manhuatai/manhuatai_cover.dart';
import 'package:flutter/material.dart';

/// Compact comic row used by the manhuatai update / rank / sort / search lists.
class ManhuataiComicTile extends StatelessWidget {
  const ManhuataiComicTile({
    super.key,
    required this.title,
    required this.imageUrl,
    this.subtitle = '',
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String imageUrl;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading ??
          ManhuataiCover(url: imageUrl, width: 44, height: 60, borderRadius: 6),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
