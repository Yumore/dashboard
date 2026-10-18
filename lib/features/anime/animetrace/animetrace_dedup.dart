import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// A run of collected anime sharing one name — the unit the dedup page shows.
class AnimeTraceDedupGroup {
  AnimeTraceDedupGroup(this.name, List<AnimeTraceAnime> animes)
    : animes = List<AnimeTraceAnime>.of(animes);

  final String name;
  final List<AnimeTraceAnime> animes;

  int get length => animes.length;

  @override
  String toString() => 'AnimeTraceDedupGroup($name, ${animes.length})';
}

/// Outcome of removing a selection of duplicates.
class AnimeTraceDedupResult {
  const AnimeTraceDedupResult({
    required this.groups,
    required this.deletedIds,
    required this.totalCount,
    required this.removedNames,
  });

  final List<AnimeTraceDedupGroup> groups;

  /// Ids that were removed (a selected id with no row is not reported).
  final List<int> deletedIds;

  /// Remaining anime across [groups].
  final int totalCount;

  /// Group names that disappeared entirely.
  final List<String> removedNames;
}

/// Pure core of the duplicate-collection cleanup.
///
/// The source app's `DedupController` mixed the grouping, the "select what can
/// go" heuristic and the deletion bookkeeping together with database calls; the
/// port keeps the same rules but as functions over plain lists, so the rules
/// are unit testable and the page only issues the resulting deletes.
class AnimeTraceDedup {
  const AnimeTraceDedup._();

  /// Groups [animes] by `animeName`, keeping first-seen order (the source app
  /// iterated the DAO's name-ordered result and pushed each new name onto a
  /// separate list).
  static List<AnimeTraceDedupGroup> groupByName(List<AnimeTraceAnime> animes) {
    final order = <String>[];
    final grouped = <String, List<AnimeTraceAnime>>{};
    for (final anime in animes) {
      final name = anime.animeName;
      final bucket = grouped[name];
      if (bucket == null) {
        order.add(name);
        grouped[name] = <AnimeTraceAnime>[anime];
      } else {
        bucket.add(anime);
      }
    }
    return <AnimeTraceDedupGroup>[
      for (final name in order) AnimeTraceDedupGroup(name, grouped[name]!),
    ];
  }

  /// The source app's "retain the ones with progress" heuristic: every anime
  /// that has **no** watched episode is pre-selected for deletion.
  static Set<int> idsWithoutProgress(List<AnimeTraceAnime> animes) {
    return <int>{
      for (final anime in animes)
        if (anime.checkedEpisodeCnt == 0 && anime.animeId > 0) anime.animeId,
    };
  }

  static int totalCount(List<AnimeTraceDedupGroup> groups) =>
      groups.fold<int>(0, (sum, group) => sum + group.length);

  /// Removes [selectedIds] from [groups] and reports the new state.
  ///
  /// A group left with one member is deliberately kept: the user may still be
  /// watching that copy, and the source app only dropped a name once its group
  /// was empty.
  static AnimeTraceDedupResult removeSelected(
    List<AnimeTraceDedupGroup> groups,
    Set<int> selectedIds,
  ) {
    final deletedIds = <int>[];
    final removedNames = <String>[];
    final remaining = <AnimeTraceDedupGroup>[];

    for (final group in groups) {
      final kept = <AnimeTraceAnime>[];
      for (final anime in group.animes) {
        if (selectedIds.contains(anime.animeId)) {
          deletedIds.add(anime.animeId);
        } else {
          kept.add(anime);
        }
      }
      if (kept.isEmpty) {
        removedNames.add(group.name);
      } else {
        remaining.add(AnimeTraceDedupGroup(group.name, kept));
      }
    }

    return AnimeTraceDedupResult(
      groups: remaining,
      deletedIds: deletedIds,
      totalCount: totalCount(remaining),
      removedNames: removedNames,
    );
  }
}
