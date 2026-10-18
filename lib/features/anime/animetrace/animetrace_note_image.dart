/// A note image stored inside the user's local note-image folder.
///
/// [path] is relative to that folder; [absolute] is only valid while the
/// configured folder is unchanged (see `AnimeTraceNoteImageStore`).
class AnimeTraceNoteImage {
  const AnimeTraceNoteImage({required this.imageId, required this.path});

  final int imageId;
  final String path;

  @override
  String toString() => 'AnimeTraceNoteImage($imageId, $path)';
}
