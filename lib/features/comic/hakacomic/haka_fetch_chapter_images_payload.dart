/// Arguments of the chapter-images endpoint
/// (`haka_comic/lib/network/models.dart:973-978`).
class HakaFetchChapterImagesPayload {
  const HakaFetchChapterImagesPayload({required this.id, required this.order});

  /// Comic id.
  final String id;

  /// Chapter `order` (not the chapter `_id`).
  final int order;
}
