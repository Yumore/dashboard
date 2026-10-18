/// A single XMLTV programme.
class MyTvProgramme {
  const MyTvProgramme({
    required this.start,
    required this.stop,
    required this.title,
  });

  /// Start instant, epoch milliseconds.
  final int start;

  /// Stop instant, epoch milliseconds.
  final int stop;

  final String title;

  /// Whether [millis] falls inside the programme's `[start, stop]` window.
  bool covers(int millis) => start <= millis && millis <= stop;

  @override
  String toString() => 'MyTvProgramme($start-$stop, $title)';
}
