/// Port of the source `Message` model (source `lib/models/message.dart:1-6`).
class FlutterSocialMessage {
  const FlutterSocialMessage(this.body, this.fromMe);

  final String body;
  final bool fromMe;
}

/// Port of the source `messages` list (source `lib/models/message.dart:8-15`).
/// This single hard-coded thread is what the source's chat screen renders for
/// every conversation.
const List<FlutterSocialMessage> flutterSocialMessages = <FlutterSocialMessage>[
  FlutterSocialMessage("Hey! How's it going? 😀", false),
  FlutterSocialMessage(
    'Great thanks, i am looking forward to meeting you tomorrow 😍',
    true,
  ),
  FlutterSocialMessage('Me too. Were you able to reach Frank?', false),
  FlutterSocialMessage('Not yet', false),
  FlutterSocialMessage("I'm sure he is asleep 😴", false),
  FlutterSocialMessage('I was thinking the exact same thing!', true),
];
