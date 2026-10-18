import 'package:flutter/material.dart';

/// Section heading used by the detail pages, replacing the source's repeated
/// inline `Padding`/`Text` header blocks.
class CinematicSectionHeader extends StatelessWidget {
  const CinematicSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
