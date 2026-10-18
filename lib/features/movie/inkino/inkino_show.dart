import 'package:dashboard/features/movie/inkino/inkino_event_images.dart';

/// One Finnkino showtime (`<Show>` inside a `<Schedule>` response).
///
/// The schedule endpoint never returns the long synopsis, so the fields this
/// carries are exactly what the showtime flow needs: identity, the age rating,
/// the sales URL, the auditorium and the start/end timestamps.
///
/// `dttmShowStart` / `dttmShowEnd` in Finnkino's XML carry no timezone offset
/// ("2018-02-21T10:30:00"), i.e. they are local cinema time, so
/// [DateTime.parse] yields a local `DateTime` and no conversion is applied.
class InKinoShow {
  const InKinoShow({
    required this.id,
    required this.eventId,
    required this.title,
    required this.originalTitle,
    required this.url,
    required this.start,
    required this.end,
    this.ageRating,
    this.ageRatingUrl,
    this.productionYear,
    this.lengthInMinutes,
    this.genres,
    this.presentationMethod,
    this.theater,
    this.theaterAuditorium,
    this.theaterAndAuditorium,
    this.images = const InKinoEventImages(),
  });

  final String id;
  final String eventId;
  final String title;
  final String originalTitle;
  final String url;
  final DateTime start;
  final DateTime end;
  final String? ageRating;
  final String? ageRatingUrl;
  final String? productionYear;
  final String? lengthInMinutes;

  /// Comma-separated in the payload, e.g. `"Komedia, Toiminta, Seikkailu"`.
  final String? genres;
  final String? presentationMethod;
  final String? theater;
  final String? theaterAuditorium;
  final String? theaterAndAuditorium;
  final InKinoEventImages images;

  bool get hasAgeRating => ageRating != null && ageRating!.isNotEmpty;

  /// `"Tennispalatsi, Helsinki, sali 6"` -> `"sali 6"`; Finnkino is not
  /// consistent about whether `<TheatreAuditorium>` is present, so this falls
  /// back to splitting the combined field.
  String get auditorium =>
      _nonEmpty(theaterAuditorium) ?? _auditoriumFromCombined() ?? '';

  /// `"Tennispalatsi, Helsinki, sali 6"` -> `"Tennispalatsi, Helsinki"`.
  String get theaterName =>
      _nonEmpty(theater) ??
      (theaterAndAuditorium == null
          ? ''
          : theaterAndAuditorium!.split(',').take(2).join(',').trim());

  List<String> get genreList => (genres ?? '')
      .split(',')
      .map((genre) => genre.trim())
      .where((genre) => genre.isNotEmpty)
      .toList();

  int? get lengthInMinutesValue =>
      int.tryParse((lengthInMinutes ?? '').replaceAll(RegExp(r'[^0-9]'), ''));

  String get startsAtLabel =>
      '${start.hour.toString().padLeft(2, '0')}:'
      '${start.minute.toString().padLeft(2, '0')}';

  String get endsAtLabel =>
      '${end.hour.toString().padLeft(2, '0')}:'
      '${end.minute.toString().padLeft(2, '0')}';

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  String? _auditoriumFromCombined() {
    final combined = theaterAndAuditorium;
    if (combined == null) return null;
    final parts = combined.split(',');
    return parts.length < 3 ? null : parts.sublist(2).join(',').trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoShow &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventId == other.eventId &&
          title == other.title &&
          originalTitle == other.originalTitle &&
          url == other.url &&
          start == other.start &&
          end == other.end &&
          ageRating == other.ageRating &&
          ageRatingUrl == other.ageRatingUrl &&
          productionYear == other.productionYear &&
          lengthInMinutes == other.lengthInMinutes &&
          genres == other.genres &&
          presentationMethod == other.presentationMethod &&
          theater == other.theater &&
          theaterAuditorium == other.theaterAuditorium &&
          theaterAndAuditorium == other.theaterAndAuditorium;

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    title,
    originalTitle,
    url,
    start,
    end,
    ageRating,
    ageRatingUrl,
    productionYear,
    lengthInMinutes,
    genres,
    presentationMethod,
    theater,
    theaterAuditorium,
    theaterAndAuditorium,
  );

  @override
  String toString() => 'InKinoShow($id, $title, $start)';
}
