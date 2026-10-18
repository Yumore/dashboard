/// Port of inKino's `EventNameCleaner`.
///
/// Finnkino deliberately encodes presentation/language variants in the title
/// itself ("Avengers: Infinity War (2D dub)"), so the UI strips that suffix
/// while the untouched [InKinoShow.originalTitle] keeps the full string.
class InKinoNameCleaner {
  const InKinoNameCleaner._();

  static final RegExp _pattern = RegExp(
    r'(\s([23]D$|\(([23]D|dub|orig|spanish|swe|sing-along).*'
    r'|\s*-\s*erikoisnäytös|\s*-\s*preview))',
    caseSensitive: false,
  );

  static String cleanup(String name) {
    final matches = _pattern.allMatches(name);
    if (matches.isEmpty) return name;
    return name.replaceFirst(matches.first.group(1)!, '');
  }
}
