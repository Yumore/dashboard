import 'package:dashboard/features/movie/inkino/inkino_content_descriptor.dart';
import 'package:dashboard/features/movie/inkino/inkino_event_images.dart';
import 'package:dashboard/features/movie/inkino/inkino_gallery_image.dart';

/// One film/event from Finnkino's `<Events>` listing (`<Event>` element).
///
/// This is the richer of the two film shapes: it is what carries the synopsis,
/// cast, director, trailer and gallery that the showtime-list `<Show>` shape
/// omits.
class InKinoEvent {
  const InKinoEvent({
    required this.id,
    required this.title,
    required this.originalTitle,
    this.releaseDate,
    this.ageRating,
    this.ageRatingUrl,
    this.genres = '',
    this.directors = const [],
    this.actors = const [],
    this.lengthInMinutes,
    this.shortSynopsis,
    this.synopsis,
    this.images = const InKinoEventImages(),
    this.contentDescriptors = const [],
    this.youtubeTrailers = const [],
    this.galleryImages = const [],
  });

  final String id;
  final String title;
  final String originalTitle;
  final DateTime? releaseDate;
  final String? ageRating;
  final String? ageRatingUrl;
  final String genres;
  final List<String> directors;
  final List<String> actors;
  final String? lengthInMinutes;
  final String? shortSynopsis;
  final String? synopsis;
  final InKinoEventImages images;
  final List<InKinoContentDescriptor> contentDescriptors;
  final List<String> youtubeTrailers;
  final List<InKinoGalleryImage> galleryImages;

  List<String> get genreList => genres
      .split(',')
      .map((genre) => genre.trim())
      .where((genre) => genre.isNotEmpty)
      .toList();

  /// The source preferred the short synopsis and fell back to the long one.
  String? get anySynopsis => _nonEmpty(shortSynopsis) ?? _nonEmpty(synopsis);

  bool get hasSynopsis => anySynopsis != null;

  int? get releaseYear => releaseDate?.year;

  int? get lengthInMinutesValue =>
      int.tryParse((lengthInMinutes ?? '').replaceAll(RegExp(r'[^0-9]'), ''));

  static String? _nonEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          originalTitle == other.originalTitle &&
          releaseDate == other.releaseDate &&
          ageRating == other.ageRating &&
          genres == other.genres &&
          directors == other.directors &&
          actors == other.actors &&
          lengthInMinutes == other.lengthInMinutes &&
          shortSynopsis == other.shortSynopsis &&
          synopsis == other.synopsis;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    originalTitle,
    releaseDate,
    ageRating,
    genres,
    directors,
    actors,
    lengthInMinutes,
    shortSynopsis,
    synopsis,
  );

  @override
  String toString() => 'InKinoEvent($id, $title)';
}
