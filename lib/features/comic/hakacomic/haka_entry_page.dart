import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry_page_state.dart';

/// Entry screen of the ported haka_comic feature.
///
/// Hosts the four ported screens as tabs; the media server is the public
/// picacomic endpoint unless [baseUrl] is supplied by the embedder.
///
/// This is the only scaffold of the feature: pushed routes (category, detail,
/// reader) build their own.
class HakaEntryPage extends StatefulWidget {
  const HakaEntryPage({super.key, this.baseUrl, this.token});

  /// Injectable API base URL. `null` keeps the public picacomic default.
  final String? baseUrl;

  /// Optional `authorization` token for logged-in requests.
  final String? token;

  @override
  State<HakaEntryPage> createState() => HakaEntryPageState();
}
