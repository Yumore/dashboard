import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';
import 'package:flutter/material.dart';

/// Port of the source user details screen (source `lib/views/user_details.dart`).
class FlutterSocialUserDetailsPage extends StatelessWidget {
  const FlutterSocialUserDetailsPage({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) {
    final user = flutterSocialUsers.singleWhere((user) => user.id == userId);
    final deviceWidth = MediaQuery.of(context).size.width;

    final cancelBtn = Positioned(
      top: 50.0,
      left: 20.0,
      child: Container(
        height: 35.0,
        width: 35.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          iconSize: 20.0,
        ),
      ),
    );

    final userImage = Stack(
      children: <Widget>[
        Hero(
          tag: user.photo,
          child: FlutterSocialPhoto(
            source: user.photo,
            width: deviceWidth,
            height: 350.0,
            borderRadius: BorderRadius.zero,
          ),
        ),
        cancelBtn,
      ],
    );

    final userName = Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Row(
        children: <Widget>[
          Text(
            user.name,
            style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            height: 30.0,
            width: 60.0,
            decoration: BoxDecoration(
              gradient: FlutterSocialPalette.chatBubbleGradient,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Center(
              // The source badge is a fixed 60x30 box holding an icon and the
              // age. A fallback font wider than the source's can exceed it (the
              // test font does), so scale down rather than overflow.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      user.gender == 'M' ? Icons.male : Icons.female,
                      color: Colors.white,
                    ),
                    Text(
                      user.age.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final userLocation = Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Text(
        user.location,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withValues(alpha: 0.8),
        ),
      ),
    );

    final aboutUser = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          width: deviceWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),
          constraints: const BoxConstraints(minHeight: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              const Text(
                'ABOUT ME',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                "My name is ${user.name} and i love meeting new people and making new friends. I love sports, reading, hiking and partying. Don't be reluctant to hit me up.",
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final hobbies = Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          width: deviceWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),
          constraints: const BoxConstraints(minHeight: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              const Text(
                'HOBBIES',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.0),
              Wrap(
                children: flutterSocialUserHobbies
                    .map((hobby) => _buildHobbiesCards(hobby))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            userImage,
            userName,
            userLocation,
            aboutUser,
            hobbies,
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesCards(String name) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      margin: const EdgeInsets.only(right: 5.0, bottom: 3.0),
      height: 30.0,
      constraints: const BoxConstraints(maxWidth: 80.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.transparent,
        border: Border.all(color: Colors.grey, width: 2.0),
      ),
      child: Center(
        child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
