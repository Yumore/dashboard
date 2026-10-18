import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_provider.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cache_page_state.dart';
import 'package:flutter/material.dart';

/// The local page cache, read back through the real sqflite provider.
///
/// The source had no screen for `lib/db/**`: the database existed only as the
/// offline fallback `HomeRepository.getDiscoverData` reaches for when the
/// connectivity interceptor answers `Code.NETWORK_ERROR`. The port keeps the
/// store and gives it one honest reader — the tags it holds and how many items
/// each one cached — instead of inventing a history feed the source never had.
class EyepetizerFlutterCachePage extends StatefulWidget {
  const EyepetizerFlutterCachePage({super.key, this.provider});

  final EyepetizerFlutterBaseListProvider? provider;

  @override
  State<EyepetizerFlutterCachePage> createState() =>
      EyepetizerFlutterCachePageState();
}
