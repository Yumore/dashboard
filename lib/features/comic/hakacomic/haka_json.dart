/// Coercion helpers shared by the hand-written model `fromJson` bodies.
///
/// The upstream `models.g.dart` generated tolerant converters for a few fields
/// (see `HakaSearchComic._likesCountFromJson`); these helpers keep that
/// behaviour without code generation.
int? hakaIntOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int hakaInt(Object? value, {int fallback = 0}) {
  return hakaIntOrNull(value) ?? fallback;
}

List<String> hakaStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item is String ? item : '$item').toList();
  }
  return const [];
}
