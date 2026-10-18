/// Container/format of a YouTube stream, derived from its MIME type.
enum YoutubeDlStreamContainer {
  mp4('mp4', 'MP4'),
  webm('webm', 'WebM'),
  m4a('m4a', 'M4A'),
  opus('opus', 'Opus'),
  unknown('bin', 'Unknown');

  const YoutubeDlStreamContainer(this.extension, this.label);

  /// File extension used when saving the stream.
  final String extension;

  /// Human readable container label.
  final String label;

  static YoutubeDlStreamContainer fromMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase();
    if (normalized.startsWith('audio/mp4')) {
      return YoutubeDlStreamContainer.m4a;
    }
    if (normalized.startsWith('audio/webm')) {
      return YoutubeDlStreamContainer.webm;
    }
    if (normalized.startsWith('video/mp4')) {
      return YoutubeDlStreamContainer.mp4;
    }
    if (normalized.startsWith('video/webm')) {
      return YoutubeDlStreamContainer.webm;
    }
    return YoutubeDlStreamContainer.unknown;
  }
}
