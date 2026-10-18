import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_home_page_state.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/person_home_page.dart` → `PersonHomePage`.
///
/// One tab of a person page. Unlike the feed pages there is no paging, no
/// refresh and no footer: the tab's `apiUrl` is requested once and its
/// `itemList` is rendered through the card factory.
class EyepetizerFlutterPersonHomePage extends StatefulWidget {
  const EyepetizerFlutterPersonHomePage({
    super.key,
    required this.url,
    required this.tabName,
    this.repository,
  });

  final String? url;
  final String tabName;
  final EyepetizerFlutterPersonRepository? repository;

  @override
  State<EyepetizerFlutterPersonHomePage> createState() =>
      EyepetizerFlutterPersonHomePageState();
}
