/// One Finnish theatre area / theatre from Finnkino's `TheatreAreas` XML.
///
/// Ids are Finnkino's own zero-padded codes (`"001"`, `"1033"`), which are sent
/// verbatim as the `area` query parameter.
class InKinoTheaterArea {
  const InKinoTheaterArea({required this.id, required this.name});

  final String id;
  final String name;

  /// The placeholder row Finnkino ships (`1029` / "Valitse alue/teatteri",
  /// "choose a theatre"). The source relabelled it "All theaters" and kept it
  /// selectable.
  bool get isPlaceholder => id == placeholderId;

  static const String placeholderId = '1029';

  /// Id of the single theatre the source defaulted to (Helsinki:
  /// Tennispalatsi), because loading the whole country first is wasteful.
  static const String defaultAreaId = '1033';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoTheaterArea &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'InKinoTheaterArea($id, $name)';
}
