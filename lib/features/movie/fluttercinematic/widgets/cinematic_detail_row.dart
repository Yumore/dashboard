import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/title_value_text.dart`: the label/value row
/// used all over the media detail page. Hidden rows (empty value) are skipped
/// by the caller.
class CinematicDetailRow extends StatelessWidget {
  const CinematicDetailRow({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(title, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
