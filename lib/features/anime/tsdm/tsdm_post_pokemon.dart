import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_pokemon_info.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Pokemon status of a post floor.
///
/// Ported from `tsdm_client/lib/widgets/card/post_card/pokemon.dart`
/// (`PostFloorPokemon.fromDiv`).
class TsdmPostPokemon {
  const TsdmPostPokemon(this.primaryPokemon, this.otherPokemon);

  /// The pokemon at the first place.
  final TsdmPokemonInfo primaryPokemon;

  /// All other pokemon shown.
  final List<TsdmPokemonInfo>? otherPokemon;

  /// Build from a `div.tsdm_pokemon` node.
  ///
  /// The `detailInfo` is the 4th single-quoted part of the `onclick`
  /// attribute, as in the source.
  static TsdmPostPokemon? fromDiv(dom.Element element) {
    final firstDetailInfo = element
        .q('a:nth-child(1)')
        ?.attributes['onclick']
        ?.split("'")
        .elementAtOrNull(3);
    final firstImage = element.q('a:nth-child(1) > img')?.imageUrl();
    final firstName = element.q('p:nth-child(2)')?.text;

    final TsdmPokemonInfo? firstPokemon;
    if (firstDetailInfo != null && firstImage != null && firstName != null) {
      firstPokemon = TsdmPokemonInfo(
        name: firstName,
        image: firstImage,
        detailInfo: firstDetailInfo,
      );
    } else {
      firstPokemon = null;
    }

    final others = element
        .qAll('p:nth-child(3) > a')
        .map((e) {
          final detailInfo = e.attributes['onclick']
              ?.split("'")
              .elementAtOrNull(3);
          final image = e.q('img')?.imageUrl();
          final name = e.q('img')?.attributes['title'];
          if (detailInfo != null && image != null && name != null) {
            return TsdmPokemonInfo(
              name: name,
              image: image,
              detailInfo: detailInfo,
            );
          }
          return null;
        })
        .whereType<TsdmPokemonInfo>()
        .toList();

    if (firstPokemon == null) {
      return null;
    }

    return TsdmPostPokemon(firstPokemon, others);
  }
}
