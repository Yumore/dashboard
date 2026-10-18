/// One film still from Finnkino's `<Gallery>` block.
class InKinoGalleryImage {
  const InKinoGalleryImage({required this.location, this.thumbnailLocation});

  final String location;
  final String? thumbnailLocation;

  String get thumbnail => thumbnailLocation ?? location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoGalleryImage &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          thumbnailLocation == other.thumbnailLocation;

  @override
  int get hashCode => Object.hash(location, thumbnailLocation);
}
