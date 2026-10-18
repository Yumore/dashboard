/// `lib/res/strings.dart` — the three cache tags the app stores pages under.
///
/// The feed pages own `discover` and `daily`; this module owns `recommend`,
/// which is what the community tab caches under.
class EyepetizerFlutterStrings {
  const EyepetizerFlutterStrings._();

  static const String discover = 'discover';
  static const String daily = 'daily';
  static const String recommend = 'recommend';

  /// The tags the local cache screen offers, in the source's declaration order.
  static const List<String> cacheTags = <String>[discover, daily, recommend];
}
