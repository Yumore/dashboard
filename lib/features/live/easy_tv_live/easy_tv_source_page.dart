import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_page_state.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_store.dart';
import 'package:flutter/material.dart';

/// Subscription management ported from the source app's `SubscribePage`:
/// list, add, select, edit and delete playlist sources.
class EasyTvSourcePage extends StatefulWidget {
  const EasyTvSourcePage({super.key, this.sourceStore});

  final EasyTvSourceStore? sourceStore;

  @override
  State<EasyTvSourcePage> createState() => EasyTvSourcePageState();
}
