import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Shared page chrome for content modules: one title style, one app bar shape
/// and one place for module level actions or tabs.
class ModulePageScaffold extends StatelessWidget {
  const ModulePageScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    super.key,
  });

  /// Standard padding for a module page that is a sectioned list.
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    ContentSpacing.md,
    ContentSpacing.md,
    ContentSpacing.md,
    ContentSpacing.xl,
  );

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ContentRadius.card),
          ),
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ContentRadius.icon),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: actions, bottom: bottom),
        body: body,
      ),
    );
  }
}
