/// The sample text pools of the FlutterSocialAppUIKit static UI demo
/// (source `lib/util/data.dart:4-44`).
///
/// Faithful porting note: the source generates its 13 chats/groups/posts/
/// notifications/friends and its 10 chat messages with an unseeded
/// `Random()` (`lib/util/data.dart:3`), so their contents change on every app
/// start. The port keeps the source's counts, field order, text pools and
/// notification formats, but resolves each random draw to a fixed index so the
/// static demo is stable and testable. Nothing was added to the pools.
class FlutterSocialAppUIKitSampleData {
  const FlutterSocialAppUIKitSampleData._();

  /// Source `names` (`lib/util/data.dart:4-16`). The source samples only the
  /// first ten entries (`random.nextInt(10)`); the eleventh name is part of the
  /// pool but was never rendered. It is kept verbatim.
  static const List<String> names = <String>[
    'Ling Waldner',
    'Gricelda Barrera',
    'Lenard Milton',
    'Bryant Marley',
    'Rosalva Sadberry',
    'Guadalupe Ratledge',
    'Brandy Gazda',
    'Kurt Toms',
    'Rosario Gathright',
    'Kim Delph',
    'Stacy Christensen',
  ];

  /// Source `messages` (`lib/util/data.dart:18-30`). The source samples only
  /// the first ten entries (`random.nextInt(10)`); `Can i hear your voice?` is
  /// part of the pool but was never rendered. It is kept verbatim.
  static const List<String> messages = <String>[
    'Hey, how are you doing?',
    'Are you available tomorrow?',
    "It's late. Go to bed!",
    'This cracked me up 😂😂',
    'Flutter Rocks!!!',
    'The last rocket🚀',
    'Griezmann signed for Barca❤️❤️',
    'Will you be attending the meetup tomorrow?',
    'Are you angry at something?',
    "Let's make a UI serie.",
    'Can i hear your voice?',
  ];

  /// Source `notifs` (`lib/util/data.dart:32-44`), with the values the source
  /// interpolates kept as `{name}` / `{count}` placeholders. The source samples
  /// only the first ten templates (`random.nextInt(10)`); the eleventh
  /// (`Sent you a friend request`) was never rendered. It is kept verbatim.
  static const List<String> notificationTemplates = <String>[
    '{name} and {count} others liked your post',
    '{name} mentioned you in a comment',
    '{name} shared your post',
    '{name} commented on your post',
    '{name} replied to your comment',
    '{name} reacted to your comment',
    '{name} asked you to join a Group️',
    '{name} asked you to like a page',
    'You have memories with {name}',
    '{name} Tagged you and {count} others in a post',
    '{name} Sent you a friend request',
  ];

  /// Renders one [notificationTemplates] entry the way the source's string
  /// interpolation did.
  static String renderNotification(
    String template, {
    required String name,
    required int count,
  }) {
    return template.replaceAll('{name}', name).replaceAll('{count}', '$count');
  }
}
