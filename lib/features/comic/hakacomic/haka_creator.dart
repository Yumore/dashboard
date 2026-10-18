import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';

/// `_creator` of a comic detail (`haka_comic/lib/network/models.dart:294-336`).
class HakaCreator {
  const HakaCreator({
    required this.id,
    required this.gender,
    required this.name,
    required this.exp,
    required this.level,
    required this.role,
    required this.characters,
    required this.title,
    this.avatar,
    this.slogan,
  });

  final String id;

  final String gender;

  final String name;

  final int exp;

  final int level;

  final String role;

  final HakaImageDetail? avatar;

  final List<String> characters;

  final String title;

  final String? slogan;

  factory HakaCreator.fromJson(Map<String, dynamic> json) {
    return HakaCreator(
      id: json['_id'] as String,
      gender: json['gender'] as String,
      name: json['name'] as String,
      exp: json['exp'] as int? ?? 0,
      level: json['level'] as int,
      role: json['role'] as String,
      avatar: json['avatar'] == null
          ? null
          : HakaImageDetail.tryParse(json['avatar']),
      characters: (json['characters'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      title: json['title'] as String? ?? '',
      slogan: json['slogan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'gender': gender,
    'name': name,
    'exp': exp,
    'level': level,
    'role': role,
    'avatar': avatar?.toJson(),
    'characters': characters,
    'title': title,
    'slogan': slogan,
  };
}
