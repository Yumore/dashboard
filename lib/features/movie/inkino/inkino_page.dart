import 'package:dashboard/features/movie/inkino/inkino_api.dart';
import 'package:dashboard/features/movie/inkino/inkino_page_state.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:flutter/material.dart';

/// Showtimes from the Finnkino XML API (the inKino migration).
class InKinoPage extends StatefulWidget {
  const InKinoPage({
    this.api,
    this.clock,
    this.onFetchAreas,
    this.defaultAreaId,
    super.key,
  });

  /// Injectable so tests can drive the page with a fake transport.
  final InKinoApi? api;

  /// Injectable so "today vs another day" is testable without a real clock.
  final DateTime Function()? clock;

  /// Injectable theatre-area loader. Defaults to the live
  /// `/xml/TheatreAreas` call, falling back to the source's bundled snapshot.
  final Future<List<InKinoTheaterArea>> Function()? onFetchAreas;

  /// Defaults to the source's `1033` (Helsinki: Tennispalatsi).
  final String? defaultAreaId;

  @override
  State<InKinoPage> createState() => InKinoPageState();
}
