import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_attention_page.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterAttentionPage].
class EyepetizerFlutterAttentionPageState
    extends State<EyepetizerFlutterAttentionPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Attention',
          style: TextStyle(fontSize: 60, color: Colors.pink),
        ),
      ),
    );
  }
}
