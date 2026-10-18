/// Formats durations the same way the source app did (`mm:ss` / `h:mm:ss`).
class YoutubeDlDuration {
  const YoutubeDlDuration._();

  static String format(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return hours > 0
        ? '$hours:$minuteText:$secondText'
        : '$minuteText:$secondText';
  }
}
