import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_available_images.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chat_preview.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_message.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_config.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_friend.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_main_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_message_type.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_notification.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_profile.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_post.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_sample_data.dart';

const List<String> _names = <String>[
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

const List<String> _messages = <String>[
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

void _useViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Finder _formFieldWithHint(String hint) {
  return find.ancestor(
    of: find.text(hint),
    matching: find.byType(TextFormField),
  );
}

Future<void> _enter(WidgetTester tester, String hint, String value) async {
  await tester.enterText(_formFieldWithHint(hint), value);
  await tester.pumpAndSettle();
}

Future<void> _pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: FlutterSocialAppUIKitDemoPage()),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpMain(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: FlutterSocialAppUIKitMainPage()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('sample data', () {
    test('names and messages are the source pools verbatim', () {
      expect(FlutterSocialAppUIKitSampleData.names, _names);
      expect(FlutterSocialAppUIKitSampleData.messages, _messages);
      expect(FlutterSocialAppUIKitSampleData.notificationTemplates.length, 11);
      expect(
        FlutterSocialAppUIKitSampleData.notificationTemplates.last,
        '{name} Sent you a friend request',
      );
    });

    test('chat list keeps 13 rows with the source field values and order', () {
      expect(flutterSocialAppUIKitChats.length, 13);
      expect(flutterSocialAppUIKitGroups.length, 13);

      expect(
        flutterSocialAppUIKitChats.map((FlutterSocialAppUIKitChatPreview row) {
          return row.name;
        }).toList(),
        <String>[
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
          'Ling Waldner',
          'Gricelda Barrera',
          'Lenard Milton',
        ],
      );
      expect(
        flutterSocialAppUIKitChats.map((FlutterSocialAppUIKitChatPreview row) {
          return row.message;
        }).toList(),
        <String>[
          "It's late. Go to bed!",
          'This cracked me up 😂😂',
          'Flutter Rocks!!!',
          'The last rocket🚀',
          'Griezmann signed for Barca❤️❤️',
          'Will you be attending the meetup tomorrow?',
          'Are you angry at something?',
          "Let's make a UI serie.",
          'Hey, how are you doing?',
          'Are you available tomorrow?',
          "It's late. Go to bed!",
          'This cracked me up 😂😂',
          'Flutter Rocks!!!',
        ],
      );

      final FlutterSocialAppUIKitChatPreview first = flutterSocialAppUIKitChats.first;
      expect(first.avatar, FlutterSocialAppUIKitAvailableImages.cm0);
      expect(first.counter, 1);
      expect(first.time, '0 min ago');
      expect(first.isOnline, isTrue);

      final FlutterSocialAppUIKitChatPreview last = flutterSocialAppUIKitChats.last;
      expect(last.message, 'Flutter Rocks!!!');
      expect(last.counter, 13);
      expect(last.time, '34 min ago');
      expect(last.isOnline, isTrue);

      expect(flutterSocialAppUIKitChats[8].counter, 9);
      expect(flutterSocialAppUIKitChats[9].isOnline, isFalse);
      expect(
        flutterSocialAppUIKitGroups.map((FlutterSocialAppUIKitChatPreview row) {
          return row.name;
        }).toList(),
        List<String>.generate(13, (int index) => 'Group ${index + 1}'),
      );
      expect(flutterSocialAppUIKitGroups.first.message, 'Flutter Rocks!!!');
      expect(flutterSocialAppUIKitGroups.first.isOnline, isFalse);
      expect(flutterSocialAppUIKitGroups[3].counter, 4);
    });

    test('chat thread has ten bubbles in the source order', () {
      expect(flutterSocialAppUIKitConversation.length, 10);

      final List<FlutterSocialAppUIKitConversationMessage> textBubbles =
          flutterSocialAppUIKitConversation.where(
        (FlutterSocialAppUIKitConversationMessage message) {
          return message.type == FlutterSocialAppUIKitMessageType.text;
        },
      ).toList();
      expect(textBubbles.length, 5);
      expect(
        textBubbles
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.message;
            })
            .toList(),
        <String>[
          'Hey, how are you doing?',
          "It's late. Go to bed!",
          'Flutter Rocks!!!',
          'Griezmann signed for Barca❤️❤️',
          'Are you angry at something?',
        ],
      );

      final List<FlutterSocialAppUIKitConversationMessage> imageBubbles =
          flutterSocialAppUIKitConversation.where(
        (FlutterSocialAppUIKitConversationMessage message) {
          return message.type == FlutterSocialAppUIKitMessageType.image;
        },
      ).toList();
      expect(
        imageBubbles
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.message;
            })
            .toList(),
        <String>[
          FlutterSocialAppUIKitAvailableImages.cm2,
          FlutterSocialAppUIKitAvailableImages.cm4,
          FlutterSocialAppUIKitAvailableImages.cm6,
          FlutterSocialAppUIKitAvailableImages.cm8,
          FlutterSocialAppUIKitAvailableImages.cm0,
        ],
      );

      expect(
        flutterSocialAppUIKitConversation
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.isMe;
            })
            .toList(),
        <bool>[false, true, false, true, false, true, false, true, false, true],
      );
      expect(
        flutterSocialAppUIKitConversation
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.isReply;
            })
            .toList(),
        <bool>[
          false,
          true,
          false,
          false,
          true,
          false,
          false,
          true,
          false,
          false,
        ],
      );
      expect(
        flutterSocialAppUIKitConversation
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.username;
            })
            .toList(),
        List<String>.generate(10, (int index) => 'Group $index'),
      );
      expect(
        flutterSocialAppUIKitConversation.every(
          (FlutterSocialAppUIKitConversationMessage message) =>
              !message.isGroup,
        ),
        isTrue,
      );
      expect(
        flutterSocialAppUIKitConversation
            .map((FlutterSocialAppUIKitConversationMessage message) {
              return message.time;
            })
            .toList(),
        <String>[
          '0 min ago',
          '9 min ago',
          '18 min ago',
          '27 min ago',
          '36 min ago',
          '45 min ago',
          '4 min ago',
          '13 min ago',
          '22 min ago',
          '31 min ago',
        ],
      );
    });

    test('feeds, notifications and friends keep the source counts and values',
        () {
      expect(flutterSocialAppUIKitPosts.length, 13);
      expect(flutterSocialAppUIKitPosts.first.name, 'Ling Waldner');
      expect(flutterSocialAppUIKitPosts.first.time, '0 min ago');
      expect(
        flutterSocialAppUIKitPosts.first.avatar,
        FlutterSocialAppUIKitAvailableImages.cm0,
      );
      expect(
        flutterSocialAppUIKitPosts.first.image,
        FlutterSocialAppUIKitAvailableImages.cm7,
      );

      expect(flutterSocialAppUIKitNotifications.length, 13);
      expect(
        flutterSocialAppUIKitNotifications
            .map((FlutterSocialAppUIKitNotification row) {
              return row.text;
            })
            .toList(),
        <String>[
          'Ling Waldner and 12 others liked your post',
          'Gricelda Barrera mentioned you in a comment',
          'Lenard Milton shared your post',
          'Bryant Marley commented on your post',
          'Rosalva Sadberry replied to your comment',
          'Guadalupe Ratledge reacted to your comment',
          'Brandy Gazda asked you to join a Group️',
          'Kurt Toms asked you to like a page',
          'You have memories with Rosario Gathright',
          'Kim Delph Tagged you and 21 others in a post',
          'Ling Waldner and 22 others liked your post',
          'Gricelda Barrera mentioned you in a comment',
          'Lenard Milton shared your post',
        ],
      );

      expect(flutterSocialAppUIKitFriends.length, 13);
      expect(
        flutterSocialAppUIKitFriends.every(
          (FlutterSocialAppUIKitFriend friend) =>
              friend.status == 'Anything could be here',
        ),
        isTrue,
      );
      expect(flutterSocialAppUIKitFriends.first.name, 'Ling Waldner');
      expect(flutterSocialAppUIKitFriends.first.isAccept, isTrue);
      expect(flutterSocialAppUIKitFriends[1].isAccept, isFalse);
      expect(flutterSocialAppUIKitFriends.last.name, 'Lenard Milton');
    });

    test('profile pins the source values and fifteen gallery pictures', () {
      expect(flutterSocialAppUIKitProfile.name, 'Bryant Marley');
      expect(
        flutterSocialAppUIKitProfile.avatar,
        FlutterSocialAppUIKitAvailableImages.cm4,
      );
      expect(flutterSocialAppUIKitProfile.status, 'Status should be here');
      expect(flutterSocialAppUIKitProfile.posts, '1234');
      expect(flutterSocialAppUIKitProfile.friends, '567');
      expect(flutterSocialAppUIKitProfile.groups, '89');
      expect(flutterSocialAppUIKitProfile.gallery.length, 15);
      expect(
        flutterSocialAppUIKitProfile.gallery.every((String image) {
          return FlutterSocialAppUIKitAvailableImages.all.contains(image);
        }),
        isTrue,
      );
    });

    test('the source has no remote sample image, only bundled assets', () {
      expect(flutterSocialAppUIKitRemoteSampleImageUrls, isEmpty);
      expect(FlutterSocialAppUIKitDemoConfig.appName, 'Chat App');
      expect(
        FlutterSocialAppUIKitDemoConfig.assetDirectory,
        'assets/fluttersocialappuikit_demo/',
      );
      final List<String> allImages = <String>[
        ...flutterSocialAppUIKitChats.map(
          (FlutterSocialAppUIKitChatPreview row) => row.avatar,
        ),
        ...flutterSocialAppUIKitGroups.map(
          (FlutterSocialAppUIKitChatPreview row) => row.avatar,
        ),
        ...flutterSocialAppUIKitPosts.map(
          (FlutterSocialAppUIKitPost post) => post.avatar,
        ),
        ...flutterSocialAppUIKitPosts.map(
          (FlutterSocialAppUIKitPost post) => post.image,
        ),
        ...flutterSocialAppUIKitNotifications.map(
          (FlutterSocialAppUIKitNotification row) => row.avatar,
        ),
        ...flutterSocialAppUIKitFriends.map(
          (FlutterSocialAppUIKitFriend friend) => friend.avatar,
        ),
        ...flutterSocialAppUIKitProfile.gallery,
        flutterSocialAppUIKitProfile.avatar,
      ];
      expect(allImages.length, 13 + 13 + 13 + 13 + 13 + 13 + 15 + 1);
      expect(
        allImages.every((String image) {
          return image.startsWith(FlutterSocialAppUIKitDemoConfig.assetDirectory);
        }),
        isTrue,
      );
      expect(
        allImages.any((String image) => image.contains('http')),
        isFalse,
      );
    });
  });

  group('login screen', () {
    testWidgets('opens on the login form of the single-screen auth flow',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(500.0, 1000.0));
      await _pumpLogin(tester);

      expect(find.text('Chat App'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Name'), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('forgot-password mode drops the password field',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(500.0, 1000.0));
      await _pumpLogin(tester);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsNothing);
      expect(find.text('Forgot Password?'), findsNothing);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('register mode adds the name field and the login switch',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(500.0, 1000.0));
      await _pumpLogin(tester);

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsNothing);
    });

    testWidgets('shows the source validation messages while typing',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(500.0, 1000.0));
      await _pumpLogin(tester);

      await _enter(tester, 'Email', 'not-an-email');
      expect(find.text('Invalid email address'), findsOneWidget);

      await _enter(tester, 'Password', '123');
      expect(find.text('Please enter a valid password.'), findsOneWidget);

      await _enter(tester, 'Email', 'jane.doe@example.com');
      expect(find.text('Invalid email address'), findsNothing);

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      await _enter(tester, 'Name', 'Jane123');
      expect(
        find.text('Please enter only alphabetical characters.'),
        findsOneWidget,
      );
      await _enter(tester, 'Name', 'Jane Doe');
      expect(
        find.text('Please enter only alphabetical characters.'),
        findsNothing,
      );
    });

    testWidgets('Submit replaces the form with the tab shell',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(500.0, 1000.0));
      await _pumpLogin(tester);

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(FlutterSocialAppUIKitMainPage), findsOneWidget);
      expect(find.byType(FlutterSocialAppUIKitDemoPage), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Feeds'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('tab shell', () {
    testWidgets('opens on Home and switches tabs from the bottom bar',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(800.0, 1200.0));
      await _pumpMain(tester);

      BottomNavigationBar navigationBar() {
        return tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
      }

      expect(navigationBar().currentIndex, 2);
      expect(find.text('Feeds'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.message));
      await tester.pumpAndSettle();
      expect(navigationBar().currentIndex, 0);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Ling Waldner'), findsWidgets);

      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Group 1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(navigationBar().currentIndex, 4);
      expect(find.text('Bryant Marley'), findsOneWidget);
      expect(find.text('Status should be here'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
      expect(find.text('567'), findsOneWidget);
      expect(find.text('89'), findsOneWidget);
      expect(find.text('Add Friend'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(navigationBar().currentIndex, 3);
      expect(find.text('Notifications'), findsOneWidget);
      expect(
        find.text('Ling Waldner and 12 others liked your post'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.group));
      await tester.pumpAndSettle();
      expect(navigationBar().currentIndex, 1);
      expect(find.text('Anything could be here'), findsWidgets);
      expect(find.text('Follow'), findsWidgets);
      expect(find.text('Unfollow'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a chat row opens the thread with its ten source bubbles',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(800.0, 1200.0));
      await _pumpMain(tester);

      await tester.tap(find.byIcon(Icons.message));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ling Waldner').first);
      await tester.pumpAndSettle();

      expect(find.byType(FlutterSocialAppUIKitConversationPage), findsOneWidget);
      expect(find.text('Ling Waldner'), findsWidgets);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Write your message...'), findsOneWidget);

      final ListView thread = tester.widget<ListView>(
        find.descendant(
          of: find.byType(FlutterSocialAppUIKitConversationPage),
          matching: find.byType(ListView),
        ),
      );
      expect(thread.reverse, isTrue);
      expect(thread.itemExtent, isNull);
      expect(find.text('Hey, how are you doing?'), findsOneWidget);
      expect(flutterSocialAppUIKitConversation.length, 10);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.keyboard_backspace));
      await tester.pumpAndSettle();
      expect(find.byType(FlutterSocialAppUIKitConversationPage), findsNothing);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('dead controls stay inert and never throw',
        (WidgetTester tester) async {
      _useViewport(tester, const Size(800.0, 1200.0));
      await _pumpMain(tester);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.group));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Follow').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Follow'), findsWidgets);
    });
  });
}
