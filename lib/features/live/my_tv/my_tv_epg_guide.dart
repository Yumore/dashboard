import 'package:dashboard/features/live/my_tv/my_tv_programme.dart';

/// Lookup helper over parsed XMLTV programmes, keyed by channel `tvgName`.
class MyTvEpgGuide {
  const MyTvEpgGuide(this.programmes);

  const MyTvEpgGuide.empty() : programmes = const {};

  final Map<String, List<MyTvProgramme>> programmes;

  bool get isEmpty => programmes.isEmpty;

  List<MyTvProgramme> programmesFor(String tvgName) =>
      programmes[tvgName] ?? const <MyTvProgramme>[];

  /// Programme covering [nowMillis], or `null`.
  MyTvProgramme? currentAt(String tvgName, int nowMillis) {
    for (final programme in programmesFor(tvgName)) {
      if (programme.covers(nowMillis)) return programme;
    }
    return null;
  }

  /// First programme starting after [nowMillis], or `null`.
  MyTvProgramme? nextAt(String tvgName, int nowMillis) {
    for (final programme in programmesFor(tvgName)) {
      if (programme.start > nowMillis) return programme;
    }
    return null;
  }
}
