import 'package:dashboard/app/platform/app_capability.dart';
import 'package:flutter/material.dart';

/// Declarative description of one destination inside a content module.
///
/// Entries are data rather than widgets: every module catalog declares them
/// once and the shared `ContentEntryCard` renders them identically on the
/// content hub, on module pages and inside demo sheets.
@immutable
class ContentEntry {
  const ContentEntry({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.accent,
    this.tooltip,
    this.builder,
    this.onTap,
    this.requires,
  }) : assert(
         builder != null || onTap != null,
         'A ContentEntry needs a builder or an onTap callback.',
       );

  /// Stable identifier, unique inside its catalog. Used by tests and by the
  /// retirement inventory to keep track of what a module actually exposes.
  final String id;

  final String title;

  /// One line of business context shown under the title.
  final String? subtitle;

  final IconData icon;

  /// Defaults to the module accent colour.
  final Color? accent;

  /// Tooltip used by icon-only hosts and by tests; defaults to [title].
  final String? tooltip;

  /// Page opened when the entry is tapped.
  final WidgetBuilder? builder;

  /// In-place action used for entries that open a sheet, a named route or a
  /// menu. Receives the tapping context so callers do not need to capture it.
  final void Function(BuildContext context)? onTap;

  /// Platform capability this entry needs.
  ///
  /// Entries whose capability is missing are filtered out of the UI instead of
  /// opening a page that would throw on the current platform.
  final AppCapability? requires;

  bool get isAvailable => requires == null || AppCapabilities.supports(requires!);
}
