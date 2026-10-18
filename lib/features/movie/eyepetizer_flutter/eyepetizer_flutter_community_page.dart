import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/community/community_page.dart` → `CommunityPage`.
///
/// Two tabs, `推荐` and `关注`, with the source's blue accent on the selected
/// label and a label-width indicator. A third route that the host's module
/// entry opens.
class EyepetizerFlutterCommunityPage extends StatefulWidget {
  const EyepetizerFlutterCommunityPage({super.key});

  @override
  State<EyepetizerFlutterCommunityPage> createState() =>
      EyepetizerFlutterCommunityPageState();
}
