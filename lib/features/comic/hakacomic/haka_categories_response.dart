import 'package:dashboard/features/comic/hakacomic/haka_category.dart';

/// `GET categories` payload (`haka_comic/lib/network/models.dart:144-154`).
class HakaCategoriesResponse {
  const HakaCategoriesResponse({required this.categories});

  final List<HakaCategory> categories;

  factory HakaCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return HakaCategoriesResponse(
      categories: (json['categories'] as List<dynamic>)
          .map((item) => HakaCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories.map((category) => category.toJson()).toList(),
  };
}
