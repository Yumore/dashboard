import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:dashboard/features/reading/easymygo/setting/source_setting_page_state.dart';
import 'package:flutter/material.dart';

/// Source settings: enable/disable, ordering and rule-package import.
class SourceSettingPage extends StatefulWidget {
  const SourceSettingPage({super.key, required this.service});

  final ReadingService service;

  @override
  State<SourceSettingPage> createState() => SourceSettingPageState();
}
