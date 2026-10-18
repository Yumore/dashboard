import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Square cover with one shared fallback for missing and broken remote images.
class ContentCover extends StatelessWidget {
  const ContentCover({
    required this.url,
    this.icon = Icons.image_outlined,
    this.size = 48,
    super.key,
  });

  final Uri? url;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, size: size * 0.6);
    final url = this.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ContentRadius.cover),
      child: SizedBox(
        height: size,
        width: size,
        child: url == null || !url.hasScheme
            ? fallback
            : Image.network(
                url.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
