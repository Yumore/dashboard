import 'package:shared_preferences/shared_preferences.dart';

class MovieEndpointStore {
  static const _key = 'content_movie_endpoint';

  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(String value) async =>
      (await SharedPreferences.getInstance()).setString(_key, value);
}
