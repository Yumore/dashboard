import 'package:shared_preferences/shared_preferences.dart';

class LiveSubscriptionStore {
  static const _key = 'content_live_subscription_url';

  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(String url) async =>
      (await SharedPreferences.getInstance()).setString(_key, url);
}
