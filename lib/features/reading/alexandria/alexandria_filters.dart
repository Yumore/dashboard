import 'package:shared_preferences/shared_preferences.dart';

/// Filter and option state for both scraped sources.
///
/// Replaces the source's static `SavedOptions` globals with an instance that can
/// be persisted through `shared_preferences`. `null` language/extension means
/// "all" (the source turned the dropdown's `all` entry into `null`), and the
/// literal [yearUnset] is the source's `"year"` sentinel for an empty year box.
class AlexandriaFilters {
  AlexandriaFilters({
    this.zlibLanguage,
    this.zlibExtension,
    this.zlibYearFrom = yearUnset,
    this.zlibYearTo = yearUnset,
    this.libGenLanguage,
    this.libGenExtension,
    this.libGenYearFrom = yearUnset,
    this.libGenYearTo = yearUnset,
  });

  static const String yearUnset = 'year';
  static const String allOption = 'all';

  /// Source list `zLibrary.languages`.
  static const List<String> zlibLanguages = <String>[
    'all',
    'english',
    'polish',
    'german',
    'russian',
    'french',
  ];

  /// Source list `zLibrary.extensions`.
  static const List<String> zlibExtensions = <String>[
    'all',
    'pdf',
    'mobi',
    'epub',
    'rtf',
    'doc',
    'txt',
    'rar',
  ];

  /// Source list `LibGen.languages`.
  static const List<String> libGenLanguages = <String>[
    'all',
    'English',
    'Polish',
    'German',
    'Russian',
    'French',
  ];

  /// Source list `LibGen.extensions`.
  static const List<String> libGenExtensions = <String>[
    'all',
    'pdf',
    'mobi',
    'epub',
    'rtf',
    'doc',
    'txt',
    'rar',
  ];

  static const String _zlibLanguageKey = 'alexandria.zlib.language';
  static const String _zlibExtensionKey = 'alexandria.zlib.extension';
  static const String _zlibYearFromKey = 'alexandria.zlib.yearFrom';
  static const String _zlibYearToKey = 'alexandria.zlib.yearTo';
  static const String _libGenLanguageKey = 'alexandria.libgen.language';
  static const String _libGenExtensionKey = 'alexandria.libgen.extension';
  static const String _libGenYearFromKey = 'alexandria.libgen.yearFrom';
  static const String _libGenYearToKey = 'alexandria.libgen.yearTo';

  String? zlibLanguage;
  String? zlibExtension;
  String zlibYearFrom;
  String zlibYearTo;

  String? libGenLanguage;
  String? libGenExtension;
  String libGenYearFrom;
  String libGenYearTo;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    zlibLanguage = _emptyToNull(prefs.getString(_zlibLanguageKey));
    zlibExtension = _emptyToNull(prefs.getString(_zlibExtensionKey));
    zlibYearFrom = _emptyToYear(prefs.getString(_zlibYearFromKey));
    zlibYearTo = _emptyToYear(prefs.getString(_zlibYearToKey));
    libGenLanguage = _emptyToNull(prefs.getString(_libGenLanguageKey));
    libGenExtension = _emptyToNull(prefs.getString(_libGenExtensionKey));
    libGenYearFrom = _emptyToYear(prefs.getString(_libGenYearFromKey));
    libGenYearTo = _emptyToYear(prefs.getString(_libGenYearToKey));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_zlibLanguageKey, zlibLanguage ?? '');
    await prefs.setString(_zlibExtensionKey, zlibExtension ?? '');
    await prefs.setString(_zlibYearFromKey, zlibYearFrom);
    await prefs.setString(_zlibYearToKey, zlibYearTo);
    await prefs.setString(_libGenLanguageKey, libGenLanguage ?? '');
    await prefs.setString(_libGenExtensionKey, libGenExtension ?? '');
    await prefs.setString(_libGenYearFromKey, libGenYearFrom);
    await prefs.setString(_libGenYearToKey, libGenYearTo);
  }

  static String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;

  static String _emptyToYear(String? value) =>
      value == null || value.isEmpty ? yearUnset : value;
}
