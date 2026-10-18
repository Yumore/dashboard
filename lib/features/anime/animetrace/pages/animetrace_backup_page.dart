import 'package:dashboard/features/anime/animetrace/animetrace_backup.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_backup_page_state.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:flutter/material.dart';

/// Device-local backup/restore of the notes database, plus an optional WebDAV
/// copy whose URL is supplied by the user (the host has no webdav_client
/// dependency, so the small subset actually needed is implemented over dio).
class AnimeTraceBackupPage extends StatefulWidget {
  const AnimeTraceBackupPage({required this.database, this.service, super.key});

  final AnimeTraceExecutorDatabase database;
  final AnimeTraceBackupService? service;

  @override
  State<AnimeTraceBackupPage> createState() => AnimeTraceBackupPageState();
}
