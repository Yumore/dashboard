/// One age/content descriptor attached to an event
/// (`<ContentDescriptors><ContentDescriptor>` in Finnkino's XML).
class InKinoContentDescriptor {
  const InKinoContentDescriptor({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoContentDescriptor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(name, imageUrl);

  @override
  String toString() => 'InKinoContentDescriptor($name, $imageUrl)';
}
