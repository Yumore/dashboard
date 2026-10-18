/// Which backend a piece of douban data came from.
///
/// The source app switched between the real client and `MockRequest` with a
/// single `useNetData` flag (`lib/repository/movie_repository.dart:44-49`), but
/// never told the UI which one answered. Every loaded result in this port
/// carries this kind so a reviewer can see the provenance.
enum FlutterDouBanSourceKind {
  network('网络', 'api.douban.com'),
  mock('本地 Mock', 'mock/');

  const FlutterDouBanSourceKind(this.label, this.origin);

  final String label;
  final String origin;
}
