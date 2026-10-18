import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';

/// Port of the source `Chat` model (source `lib/models/chat.dart:3-9`).
class FlutterSocialChat {
  const FlutterSocialChat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.unreadCount,
    required this.message,
  });

  final int id;
  final int userId;
  final String userName;
  final String userImage;
  final int unreadCount;
  final String message;
}

/// Port of the source `chats` list (source `lib/models/chat.dart:11-16`).
/// The source builds each entry from `users[1..4]`, so the same derivation is
/// kept here instead of duplicating the names and photos as literals.
final List<FlutterSocialChat> flutterSocialChats = <FlutterSocialChat>[
  FlutterSocialChat(
    id: 1,
    userId: flutterSocialUsers[1].id,
    userName: flutterSocialUsers[1].name,
    userImage: flutterSocialUsers[1].photo,
    unreadCount: 3,
    message: "Hey! How's it going?",
  ),
  FlutterSocialChat(
    id: 2,
    userId: flutterSocialUsers[2].id,
    userName: flutterSocialUsers[2].name,
    userImage: flutterSocialUsers[2].photo,
    unreadCount: 1,
    message: 'What kind of music do you like?',
  ),
  FlutterSocialChat(
    id: 3,
    userId: flutterSocialUsers[3].id,
    userName: flutterSocialUsers[3].name,
    userImage: flutterSocialUsers[3].photo,
    unreadCount: 0,
    message: 'Sound good to me.',
  ),
  FlutterSocialChat(
    id: 4,
    userId: flutterSocialUsers[4].id,
    userName: flutterSocialUsers[4].name,
    userImage: flutterSocialUsers[4].photo,
    unreadCount: 0,
    message: 'Sure, see you on Saturday.',
  ),
];
