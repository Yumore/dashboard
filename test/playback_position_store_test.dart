import 'package:dashboard/features/media/playback_position_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'resume positions survive store recreation and remain per episode',
    () async {
      SharedPreferences.setMockInitialValues({});
      await PlaybackPositionStore().save(
        'episode-a',
        const Duration(seconds: 84),
      );
      final reopened = PlaybackPositionStore();
      expect(await reopened.load('episode-a'), const Duration(seconds: 84));
      expect(await reopened.load('episode-b'), Duration.zero);
      await reopened.save('episode-a', const Duration(seconds: -1));
      expect(await reopened.load('episode-a'), Duration.zero);
    },
  );
}
