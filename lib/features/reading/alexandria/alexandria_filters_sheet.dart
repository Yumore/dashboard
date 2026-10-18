import 'package:dashboard/features/reading/alexandria/alexandria_filters.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_filters_sheet_state.dart';
import 'package:flutter/material.dart';

/// Bottom sheet that edits [AlexandriaFilters]; pops `true` when the user
/// applies a change. Replaces the source's Options drawer section.
class AlexandriaFiltersSheet extends StatefulWidget {
  const AlexandriaFiltersSheet({required this.filters, super.key});

  final AlexandriaFilters filters;

  @override
  State<AlexandriaFiltersSheet> createState() => AlexandriaFiltersSheetState();
}
