import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_actor_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/actor_detail_page.dart` (Person tab view):
/// a `TabBar` with `Movies` (`discover/movie?with_cast={id}`) and
/// `TV Shows` (`person/{id}/tv_credits`).
class CinematicActorPage extends StatefulWidget {
  const CinematicActorPage({
    required this.actorId,
    required this.name,
    this.api,
    super.key,
  });

  final int actorId;
  final String name;
  final CinematicApi? api;

  @override
  State<CinematicActorPage> createState() => CinematicActorPageState();
}
