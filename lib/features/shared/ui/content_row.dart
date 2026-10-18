import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Standard row for content driven by a remote cover (anime shows, movies,
/// live channels, local conversations).
class ContentRow extends StatelessWidget {
  const ContentRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.trailing = const Icon(Icons.chevron_right),
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Custom leading widget (a cover or avatar). When null, [leadingIcon] is
  /// rendered as the leading icon instead.
  final Widget? leading;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final leading = this.leading;
    final leadingIcon = this.leadingIcon;
    return Card(
      margin: const EdgeInsets.only(bottom: ContentSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: leading ?? (leadingIcon == null ? null : Icon(leadingIcon)),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null || subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
