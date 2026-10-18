/// Port of `AudioLink` from the source `lib/entities.dart`.
///
/// The demo never streams [url]: the host has no flutter_sound/music player
/// for this module and the demo must stay offline. The values stay available
/// for display and for comparison with the source seed.
class FakeWechatAudioLink {
  const FakeWechatAudioLink({
    required this.cover,
    required this.name,
    required this.artist,
    required this.url,
  });

  final String cover;
  final String name;
  final String artist;
  final String url;
}
