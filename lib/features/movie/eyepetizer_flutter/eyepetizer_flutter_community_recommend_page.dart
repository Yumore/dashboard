import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_recommend_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/community/recommend_page.dart` → `RecommendPage`.
///
/// Kept as its own page because the community screen's first tab is this feed
/// and nothing else.
class EyepetizerFlutterCommunityRecommendPage extends StatefulWidget {
  const EyepetizerFlutterCommunityRecommendPage({super.key, this.repository});

  final EyepetizerFlutterCommunityRepository? repository;

  @override
  State<EyepetizerFlutterCommunityRecommendPage> createState() =>
      EyepetizerFlutterCommunityRecommendPageState();
}
