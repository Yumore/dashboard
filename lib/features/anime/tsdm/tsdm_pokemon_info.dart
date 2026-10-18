/// Info about a single pokemon shown in a post floor.
///
/// Ported from `tsdm_client/lib/widgets/card/post_card/pokemon.dart`.
class TsdmPokemonInfo {
  const TsdmPokemonInfo({
    required this.name,
    required this.image,
    required this.detailInfo,
  });

  /// Pokemon name.
  final String name;

  /// Url of the pokemon appearance image.
  final String image;

  /// Detail info used by the pokemon dialog.
  final String detailInfo;
}
