import 'package:flutter/material.dart';

/// `ViewCardUtil`'s `textCard` branch (the source's `TitleCard`).
class EyepetizerFlutterTextCard extends StatelessWidget {
  const EyepetizerFlutterTextCard({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      alignment: Alignment.centerLeft,
      child: Text(
        title ?? '',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
