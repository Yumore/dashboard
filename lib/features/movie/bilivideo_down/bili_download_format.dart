/// The stream containers bilibili can answer a play-url request with.
///
/// The source app's `platform=html5` request only ever produced [flv] (B
/// station's progressive `durl` stream, served as FLV or MP4); [dash] is what
/// an `fnval`-enabled request returns instead.
enum BiliDownloadFormat {
  /// Progressive `durl` segments — what the source app downloaded.
  flv,

  /// Segmented `dash` video/audio tracks.
  dash;

  String get label => this == BiliDownloadFormat.dash ? 'DASH' : 'FLV';

  /// File extension used for the downloaded artefact.
  String get extension => 'mp4';
}
