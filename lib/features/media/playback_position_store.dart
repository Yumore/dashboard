import 'package:shared_preferences/shared_preferences.dart';

class PlaybackPositionStore {
  String _key(String id) => 'content.playback.position.$id';

  Future<Duration> load(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return Duration(milliseconds: prefs.getInt(_key(id)) ?? 0);
  }

  Future<void> save(String id, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(id), position.inMilliseconds.clamp(0, 1 << 53));
  }
}
