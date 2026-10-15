import 'package:dashboard/features/live/billd_live_page_state.dart';
import 'package:dashboard/features/live/billd_live_repository.dart';
import 'package:flutter/material.dart';

class BilldLivePage extends StatefulWidget {
  const BilldLivePage({super.key, this.repository});

  final BilldLiveRepository? repository;

  @override
  State<BilldLivePage> createState() => BilldLivePageState();
}
