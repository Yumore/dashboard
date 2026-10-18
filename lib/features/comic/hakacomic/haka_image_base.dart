/// Read-only image abstraction used by the reader so local and remote pages
/// can be mixed (`haka_comic/lib/network/models.dart:980-985`).
abstract class HakaImageBase {
  const HakaImageBase();

  String get url;

  String? get cacheKey;

  String? get id;

  String get uid;
}
