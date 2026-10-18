import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_available_images.dart';

/// Port of the source `User` model (source `lib/models/user.dart:3-12`).
class FlutterSocialUser {
  const FlutterSocialUser({
    required this.id,
    required this.name,
    required this.photo,
    required this.gender,
    required this.age,
    this.location = 'Seattle, USA.',
  });

  final int id;
  final String name;
  final String photo;
  final String location;
  final String gender;
  final int age;
}

/// Port of the source `users` list (source `lib/models/user.dart:16-27`).
/// Names come from the comment at `lib/models/user.dart:15`.
const List<FlutterSocialUser> flutterSocialUsers = <FlutterSocialUser>[
  FlutterSocialUser(
    id: 1,
    name: 'Matt Maxwell',
    photo: FlutterSocialAvailableImages.man1,
    gender: 'M',
    age: 27,
  ),
  FlutterSocialUser(
    id: 2,
    name: 'Maria Perez',
    photo: FlutterSocialAvailableImages.woman1,
    gender: 'F',
    age: 24,
  ),
  FlutterSocialUser(
    id: 3,
    name: 'Craig Jordan',
    photo: FlutterSocialAvailableImages.man2,
    gender: 'M',
    age: 28,
  ),
  FlutterSocialUser(
    id: 4,
    name: 'Charlotte Mckenzie',
    photo: FlutterSocialAvailableImages.woman2,
    gender: 'F',
    age: 23,
  ),
  FlutterSocialUser(
    id: 5,
    name: 'Rita Pena',
    photo: FlutterSocialAvailableImages.woman3,
    gender: 'F',
    age: 25,
  ),
  FlutterSocialUser(
    id: 6,
    name: 'Robin Mcguire',
    photo: FlutterSocialAvailableImages.man3,
    gender: 'M',
    age: 29,
  ),
  FlutterSocialUser(
    id: 7,
    name: 'Angelina Love',
    photo: FlutterSocialAvailableImages.woman4,
    gender: 'F',
    age: 22,
  ),
  FlutterSocialUser(
    id: 8,
    name: 'Louis Diaz',
    photo: FlutterSocialAvailableImages.man4,
    gender: 'M',
    age: 23,
  ),
  FlutterSocialUser(
    id: 9,
    name: 'Kyle Poole',
    photo: FlutterSocialAvailableImages.man5,
    gender: 'M',
    age: 25,
  ),
  FlutterSocialUser(
    id: 10,
    name: 'Brenda Watkins',
    photo: FlutterSocialAvailableImages.woman5,
    gender: 'F',
    age: 26,
  ),
];

/// Port of the source `userHobbies` list (source `lib/models/user.dart:29-31`).
const List<String> flutterSocialUserHobbies = <String>[
  'Dancing',
  'Hiking',
  'Singing',
  'Reading',
  'Fishing',
];
