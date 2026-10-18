/// The `<Images>` block of a Finnkino event or show.
///
/// Field names follow Finnkino's own tags one-to-one so the mapping stays
/// auditable against the API documentation.
class InKinoEventImages {
  const InKinoEventImages({
    this.portraitMicro,
    this.portraitSmall,
    this.portraitMedium,
    this.portraitLarge,
    this.landscapeSmall,
    this.landscapeLarge,
  });

  final String? portraitMicro;
  final String? portraitSmall;
  final String? portraitMedium;
  final String? portraitLarge;
  final String? landscapeSmall;
  final String? landscapeLarge;

  /// First image that is actually present, used for list thumbnails.
  String? get anyPortrait =>
      portraitSmall ?? portraitMedium ?? portraitLarge ?? portraitMicro;

  String? get anyAvailable => anyPortrait ?? landscapeSmall ?? landscapeLarge;

  bool get isEmpty =>
      anyAvailable == null &&
      portraitMicro == null &&
      portraitSmall == null &&
      portraitMedium == null &&
      portraitLarge == null &&
      landscapeSmall == null &&
      landscapeLarge == null;

  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoEventImages &&
          runtimeType == other.runtimeType &&
          portraitMicro == other.portraitMicro &&
          portraitSmall == other.portraitSmall &&
          portraitMedium == other.portraitMedium &&
          portraitLarge == other.portraitLarge &&
          landscapeSmall == other.landscapeSmall &&
          landscapeLarge == other.landscapeLarge;

  @override
  int get hashCode => Object.hash(
    portraitMicro,
    portraitSmall,
    portraitMedium,
    portraitLarge,
    landscapeSmall,
    landscapeLarge,
  );
}
