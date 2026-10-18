import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:flutter/material.dart';

/// A titled group of entries. Sections are the only layout primitive module
/// pages use for navigation, which keeps every page structurally identical.
@immutable
class ContentEntrySection {
  const ContentEntrySection({
    required this.title,
    required this.entries,
    this.description,
  });

  final String title;

  /// Optional one-line explanation rendered under the section title.
  final String? description;

  final List<ContentEntry> entries;
}
