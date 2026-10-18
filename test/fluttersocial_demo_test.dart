import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_available_images.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat_bubble.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chat_thread_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chats_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_config.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card1.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card2.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feed_card3.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_home_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_login_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_message.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_notifications_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_profile_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_register_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_reset_password_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps a tab in the ported shell. The active tab's own page repeats the label
/// (the chats tab, for example, is titled `Chats`), so the finder is scoped to
/// the navigation bar.
Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ported flutter-social sample data', () {
    test('users match the source list, in the source order', () {
      expect(flutterSocialUsers.length, 10);
      expect(flutterSocialUsers.map((user) => user.id).toList(), <int>[
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
      ]);
      expect(flutterSocialUsers.map((user) => user.name).toList(), <String>[
        'Matt Maxwell',
        'Maria Perez',
        'Craig Jordan',
        'Charlotte Mckenzie',
        'Rita Pena',
        'Robin Mcguire',
        'Angelina Love',
        'Louis Diaz',
        'Kyle Poole',
        'Brenda Watkins',
      ]);
      expect(flutterSocialUsers.map((user) => user.photo).toList(), <String>[
        FlutterSocialAvailableImages.man1,
        FlutterSocialAvailableImages.woman1,
        FlutterSocialAvailableImages.man2,
        FlutterSocialAvailableImages.woman2,
        FlutterSocialAvailableImages.woman3,
        FlutterSocialAvailableImages.man3,
        FlutterSocialAvailableImages.woman4,
        FlutterSocialAvailableImages.man4,
        FlutterSocialAvailableImages.man5,
        FlutterSocialAvailableImages.woman5,
      ]);
      expect(flutterSocialUsers.map((user) => user.gender).toList(), <String>[
        'M', 'F', 'M', 'F', 'F', 'M', 'F', 'M', 'M', 'F',
      ]);
      expect(flutterSocialUsers.map((user) => user.age).toList(), <int>[
        27, 24, 28, 23, 25, 29, 22, 23, 25, 26,
      ]);
      expect(
        flutterSocialUsers.every((user) => user.location == 'Seattle, USA.'),
        isTrue,
      );
    });

    test('user hobbies match the source list, in the source order', () {
      expect(flutterSocialUserHobbies, <String>[
        'Dancing',
        'Hiking',
        'Singing',
        'Reading',
        'Fishing',
      ]);
    });

    test('chats match the source list, in the source order', () {
      expect(flutterSocialChats.length, 4);
      expect(flutterSocialChats.map((chat) => chat.id).toList(), <int>[
        1, 2, 3, 4,
      ]);
      // The source derives each chat from users[1..4].
      expect(flutterSocialChats.map((chat) => chat.userId).toList(), <int>[
        2, 3, 4, 5,
      ]);
      expect(flutterSocialChats.map((chat) => chat.userName).toList(), <String>[
        'Maria Perez',
        'Craig Jordan',
        'Charlotte Mckenzie',
        'Rita Pena',
      ]);
      expect(flutterSocialChats.map((chat) => chat.unreadCount).toList(), <int>[
        3, 1, 0, 0,
      ]);
      expect(flutterSocialChats.map((chat) => chat.message).toList(), <String>[
        "Hey! How's it going?",
        'What kind of music do you like?',
        'Sound good to me.',
        'Sure, see you on Saturday.',
      ]);
      for (var index = 0; index < flutterSocialChats.length; index++) {
        expect(flutterSocialChats[index].userImage, flutterSocialUsers[index + 1].photo);
      }
    });

    test('the chat thread has the source bubbles, in the source order', () {
      expect(flutterSocialMessages.length, 6);
      expect(flutterSocialMessages.map((message) => message.body).toList(), <String>[
        "Hey! How's it going? 😀",
        'Great thanks, i am looking forward to meeting you tomorrow 😍',
        'Me too. Were you able to reach Frank?',
        'Not yet',
        "I'm sure he is asleep 😴",
        'I was thinking the exact same thing!',
      ]);
      expect(flutterSocialMessages.map((message) => message.fromMe).toList(), <bool>[
        false, true, false, false, false, true,
      ]);
    });

    test('feeds match the source list, in the source order', () {
      expect(flutterSocialFeeds.length, 4);
      expect(flutterSocialFeeds.map((feed) => feed.createdAt).toList(), <String>[
        '19 Aug',
        '20 Aug',
        '22 Aug',
        '1 Sept',
      ]);
      expect(flutterSocialFeeds.map((feed) => feed.userId).toList(), <int>[
        1, 2, 3, 4,
      ]);
      expect(flutterSocialFeeds.map((feed) => feed.userName).toList(), <String>[
        'Matt Maxwell',
        'Maria Perez',
        'Craig Jordan',
        'Charlotte Mckenzie',
      ]);
      const lorem =
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum id neque libero. Donec finibus sem viverra.';
      expect(
        flutterSocialFeeds.every((feed) => feed.description == lorem),
        isTrue,
      );
      expect(
        flutterSocialFeeds.every((feed) => feed.bannerImg == FlutterSocialAvailableImages.postBanner),
        isTrue,
      );
    });

    test('the source carries no remote image URL to port', () {
      // Faithful record: every picture in the source is a bundled asset path and
      // its only URL is the random-name-generator comment at
      // lib/models/user.dart:15, so there is no remote sample image to keep.
      expect(flutterSocialDemoRemoteSampleImageUrls, isEmpty);
      final List<String> assetPaths = <String>[
        FlutterSocialAvailableImages.man1,
        FlutterSocialAvailableImages.man2,
        FlutterSocialAvailableImages.man3,
        FlutterSocialAvailableImages.man4,
        FlutterSocialAvailableImages.man5,
        FlutterSocialAvailableImages.woman1,
        FlutterSocialAvailableImages.woman2,
        FlutterSocialAvailableImages.woman3,
        FlutterSocialAvailableImages.woman4,
        FlutterSocialAvailableImages.woman5,
        FlutterSocialAvailableImages.postBanner,
        FlutterSocialAvailableImages.emptyState,
        FlutterSocialAvailableImages.homePage,
        FlutterSocialAvailableImages.appLogo,
      ];
      expect(assetPaths.length, 14);
      expect(
        assetPaths.every(
          (path) => path.startsWith('assets/fluttersocial_demo/'),
        ),
        isTrue,
      );
      expect(FlutterSocialDemoConfig.appName, 'Heart String');
      expect(FlutterSocialDemoConfig.appTagline, 'Find your perfect match');
    });
  });

  group('ported flutter-social screens', () {
    testWidgets('landing screen opens the log-in screen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialDemoPage()));
      expect(find.text('Heart String'), findsOneWidget);
      expect(find.text('Find your perfect match'), findsOneWidget);
      expect(find.text('LOG IN'), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);

      await tester.tap(find.text('LOG IN'));
      await tester.pumpAndSettle();

      expect(find.text('Log In.'), findsOneWidget);
      expect(find.text('We missed you!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('landing screen opens the sign-up screen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialDemoPage()));

      await tester.tap(find.text('SIGN UP'));
      await tester.pumpAndSettle();

      expect(find.text('Tell us about you.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'log-in has no validation rules in the source, so empty fields continue',
        (tester) async {
      // Source views/login.dart:13-14 creates a GlobalKey<FormState> and
      // views/login.dart:87 attaches it to a Form, but no `validator` and no
      // validate() call exists anywhere in the source screens (verified by grep
      // over lib/views/), so SIGN IN always continues.
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialLoginPage()));
      expect(find.text('Log In.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Log In.'), findsNothing);
    });

    testWidgets('forgot-password flow keeps the source routes', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialLoginPage()));

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.byType(FlutterSocialResetPasswordPage), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(1));

      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();
      expect(find.text('Heart String'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'sign-up selects a gender but applies no other validation, like the source',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialRegisterPage()));
      expect(find.text('Tell us about you.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(Radio<int>), findsNWidgets(3));
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(
        tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
        -1,
      );

      // Male is 0, Female 1, Other 2 in the source.
      await tester.ensureVisible(find.byType(Radio<int>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Radio<int>).at(1));
      await tester.pump();
      expect(
        tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
        1,
      );

      // Still no `validator` on the four fields: empty values continue.
      await tester.ensureVisible(find.text('CREATE ACCOUNT'));
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('tab shell switches between the four source tabs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialHomePage()));

      // Tab 0 is the feed tab and shows the first three source feeds.
      expect(find.byType(FlutterSocialFeedCard1), findsOneWidget);
      expect(find.byType(FlutterSocialFeedCard2), findsOneWidget);
      expect(find.byType(FlutterSocialFeedCard3), findsOneWidget);
      expect(find.text('Matt Maxwell'), findsOneWidget);
      expect(find.text('19 Aug'), findsOneWidget);

      await _tapTab(tester, 'Chats');
      expect(find.byType(FlutterSocialChatsPage), findsOneWidget);
      expect(find.text('ONLINE USERS'), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.byType(FlutterSocialFeedCard1), findsNothing);

      await _tapTab(tester, 'Notifications');
      expect(find.byType(FlutterSocialNotificationsPage), findsOneWidget);
      expect(find.text('No New Notification'), findsOneWidget);
      expect(
        find.text('You currently do not have any unread notifications.'),
        findsOneWidget,
      );

      await _tapTab(tester, 'Profile');
      expect(find.byType(FlutterSocialProfilePage), findsOneWidget);
      expect(find.text('Matt Maxwell'), findsOneWidget);
      expect(find.text('Seattle, USA.'), findsOneWidget);
      expect(find.text('VISITORS'), findsOneWidget);
      expect(find.text('2305'), findsOneWidget);
      expect(find.text('LIKED'), findsOneWidget);
      expect(find.text('276'), findsOneWidget);
      expect(find.text('MATCHED'), findsOneWidget);
      expect(find.text('51'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _tapTab(tester, 'Feed');
      expect(find.byType(FlutterSocialFeedCard1), findsOneWidget);
    });

    testWidgets('the chat list shows the source conversations', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialChatsPage()));

      expect(find.text('Maria Perez'), findsOneWidget);
      expect(find.text('Craig Jordan'), findsOneWidget);
      expect(find.text('Charlotte Mckenzie'), findsOneWidget);
      expect(find.text('Rita Pena'), findsOneWidget);
      expect(find.text("Hey! How's it going?"), findsOneWidget);
      expect(find.text('What kind of music do you like?'), findsOneWidget);
      expect(find.text('Sound good to me.'), findsOneWidget);
      expect(find.text('Sure, see you on Saturday.'), findsOneWidget);
      // Unread badges exist only for the first two conversations.
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      // The ten source users feed the horizontal online row. Nine fit the test
      // viewport, and the tenth is reachable by scrolling the row.
      expect(find.text('Matt'), findsOneWidget);
      expect(find.text('Brenda'), findsNothing);
      await tester.dragUntilVisible(
        find.text('Brenda'),
        find.byType(ListView).first,
        const Offset(-100.0, 0.0),
      );
      expect(find.text('Brenda'), findsOneWidget);
    });

    testWidgets('the chat list opens the thread of the tapped conversation',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialHomePage()));
      await _tapTab(tester, 'Chats');

      await tester.tap(find.text('Maria Perez'));
      await tester.pumpAndSettle();

      expect(find.byType(FlutterSocialChatThreadPage), findsOneWidget);
      // The thread belongs to user 2 (Maria Perez), not to user 1.
      expect(find.text('Maria Perez'), findsOneWidget);
      expect(find.text('Matt Maxwell'), findsNothing);
      expect(find.byType(FlutterSocialChatBubble), findsNWidgets(6));
      for (final message in flutterSocialMessages) {
        expect(find.text(message.body), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('a second conversation opens its own thread', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialChatsPage()));

      await tester.ensureVisible(find.text('Craig Jordan'));
      await tester.tap(find.text('Craig Jordan'));
      await tester.pumpAndSettle();

      expect(find.text('Craig Jordan'), findsOneWidget);
      expect(find.text('Maria Perez'), findsNothing);
      // The source renders the same hard-coded thread for every conversation.
      expect(find.byType(FlutterSocialChatBubble), findsNWidgets(6));
    });

    testWidgets('the thread keeps the source send/camera buttons inert',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FlutterSocialChatThreadPage(userId: 2)),
      );
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Empty callbacks in the source: nothing is sent, the thread is unchanged.
      expect(find.byType(FlutterSocialChatBubble), findsNWidgets(6));
      expect(find.text('hello'), findsOneWidget); // typed text is not cleared either
      expect(tester.takeException(), isNull);
    });

    testWidgets('the thread avatar opens the user details screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FlutterSocialChatThreadPage(userId: 2)),
      );

      // The clip and the placeholder are deliberately hit-transparent, so the
      // tap is aimed at the photo's centre and lands on the wrapping InkWell.
      await tester.tapAt(tester.getCenter(find.byType(FlutterSocialPhoto)));
      await tester.pumpAndSettle();

      expect(find.byType(FlutterSocialUserDetailsPage), findsOneWidget);
      expect(find.text('Maria Perez'), findsOneWidget);
      expect(find.byIcon(Icons.female), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Seattle, USA.'), findsOneWidget);
      expect(find.text('ABOUT ME'), findsOneWidget);
      expect(
        find.textContaining('My name is Maria Perez'),
        findsOneWidget,
      );
      expect(find.text('HOBBIES'), findsOneWidget);
      for (final hobby in flutterSocialUserHobbies) {
        expect(find.text(hobby), findsOneWidget);
      }

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('ABOUT ME'), findsNothing);
      expect(find.byType(FlutterSocialChatThreadPage), findsOneWidget);
    });

    testWidgets('the chat search field stays inert, like the source',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialChatsPage()));

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      // The source field has no controller and no filtering: every chat stays.
      for (final chat in flutterSocialChats) {
        expect(find.text(chat.userName), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('the profile rows are display-only, like the source',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlutterSocialProfilePage()));

      for (final title in <String>[
        'Likes',
        'Visitors',
        'Groups',
        'My Wallet',
        'VIP Center',
        'Find Friends',
        'Blacklist',
        'Settings',
      ]) {
        expect(find.text(title), findsOneWidget);
      }

      await tester.ensureVisible(find.text('My Wallet'));
      await tester.tap(find.text('My Wallet'));
      await tester.pumpAndSettle();

      // No onTap in the source profile list: nothing is pushed.
      expect(find.byType(FlutterSocialProfilePage), findsOneWidget);
      expect(find.text('VISITORS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
