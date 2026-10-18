import 'package:flutter/material.dart';

/// Compile-time configuration for the FlutterCinematic port.
///
/// The source app hard-coded its TMDb key in `lib/util/constants.dart` as the
/// literal `<your-api-key>` (invalid Dart), so this port keeps the key
/// injectable instead of baking a real credential into the tree:
///
/// * [defaultApiKey] is the const placeholder the source shipped with;
/// * `CinematicApi` accepts an explicit `apiKey` override.
class CinematicConstants {
  const CinematicConstants._();

  static const String defaultApiKey = '<your-api-key>';
  static const String defaultLanguage = 'en-US';

  static const String baseUrl = 'https://api.themoviedb.org/3/';

  /// TMDb image base. The source only ever built `w500` (large backdrop) and
  /// `w300` (medium poster/avatar/still) URLs.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String backdropSize = 'w500';
  static const String posterSize = 'w300';

  /// Public IMDb title page, used by the detail meta section.
  static const String imdbTitleBase = 'http://www.imdb.com/title/';

  /// Source palette (`lib/util/styles.dart`).
  static const Color primary = Color(0xFF2C2B33);
  static const Color primaryDark = Color(0xFF222128);
  static const Color colorAccent = Color(0xFF65BFA6);
  static const Color salmon = Color(0xFFF47663);

  /// Home page list categories, per media type (`lib/widgets/home_page.dart`).
  static const List<String> movieCategories = <String>[
    'popular',
    'upcoming',
    'top_rated',
  ];
  static const List<String> showCategories = <String>[
    'popular',
    'on_the_air',
    'top_rated',
  ];

  /// `Locale('en_US')` month names for [formatDate]; `intl` is not a host
  /// dependency, so the formatting is hand-written.
  static const List<String> monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
