import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_repository.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_page_state.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_settings_store.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_store.dart';
import 'package:flutter/material.dart';

/// Home screen of the easy_tv_live port: the live-channel catalog with its
/// group/channel drawer (`LiveHomePage` + `ChannelDrawerPage` in the source).
class EasyTvPage extends StatefulWidget {
  const EasyTvPage({
    super.key,
    this.repository,
    this.sourceStore,
    this.settingsStore,
  });

  /// Injectable for tests; a real repository is created otherwise.
  final EasyTvCatalogRepository? repository;
  final EasyTvSourceStore? sourceStore;
  final EasyTvSettingsStore? settingsStore;

  @override
  State<EasyTvPage> createState() => EasyTvPageState();
}
