import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// One backup file on the device.
class AnimeTraceBackupFile {
  const AnimeTraceBackupFile({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
    required this.modified,
  });

  final String path;
  final String fileName;
  final int sizeBytes;
  final DateTime modified;
}

/// Device-local backup/restore of the AnimeTrace database, plus an optional
/// WebDAV copy.
///
/// The source app used `webdav_client`; that package is not a host dependency,
/// so only the small subset this feature needs is implemented directly over the
/// already-present `dio`: `MKCOL` to create the remote folder plus `PUT`/`GET`
/// for the single backup file. The remote URL is always supplied by the caller
/// from user input — nothing is contacted implicitly.
class AnimeTraceBackupService {
  AnimeTraceBackupService({
    required this.database,
    Dio? dio,
    Future<Directory> Function()? directoryProvider,
    this.remoteDirectory = 'animetrace',
    this.remoteFileName = 'anime_trace_backup.db',
    this.timeout = const Duration(seconds: 30),
  }) : _dio = dio ?? Dio(),
       _directoryProvider = directoryProvider ?? _defaultDirectoryProvider;

  final AnimeTraceExecutorDatabase database;
  final Dio _dio;
  final Future<Directory> Function() _directoryProvider;
  final String remoteDirectory;
  final String remoteFileName;
  final Duration timeout;

  static Future<Directory> _defaultDirectoryProvider() =>
      getApplicationDocumentsDirectory();

  /// Folder holding device backups, created on demand.
  Future<Directory> backupDirectory() async {
    final documents = await _directoryProvider();
    final directory = Directory(
      '${documents.path}${Platform.pathSeparator}animetrace'
      '${Platform.pathSeparator}backups',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Timestamped backup file name, e.g. `anime_trace_20261017_071530.db`.
  static String backupFileName(DateTime now) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'anime_trace_${now.year}${two(now.month)}${two(now.day)}'
        '_${two(now.hour)}${two(now.minute)}${two(now.second)}.db';
  }

  /// Copies the live database into the backup folder and returns the new file.
  ///
  /// The database is closed first so SQLite flushes every page; it is reopened
  /// before returning, so a failed copy leaves the app usable.
  Future<File> backupToDevice({DateTime? now}) async {
    final sourcePath = database.path;
    if (sourcePath.isEmpty) {
      throw StateError('数据库尚未打开，无法备份');
    }
    final directory = await backupDirectory();
    final stamp = now ?? DateTime.now();
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      '${backupFileName(stamp)}',
    );

    if (database.isOpen) await database.close();
    try {
      await File(sourcePath).copy(target.path);
    } finally {
      await database.open();
    }
    return target;
  }

  /// Backup files on the device, newest first.
  Future<List<AnimeTraceBackupFile>> listDeviceBackups() async {
    final directory = await backupDirectory();
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.db'))
            .map(
              (file) => AnimeTraceBackupFile(
                path: file.path,
                fileName: file.path.split(Platform.pathSeparator).last,
                sizeBytes: file.lengthSync(),
                modified: file.lastModifiedSync(),
              ),
            )
            .toList()
          ..sort((a, b) => b.modified.compareTo(a.modified));
    return files;
  }

  /// Replaces the live database with [backupPath] and reopens it.
  Future<void> restoreFromDevice(String backupPath) async {
    final source = File(backupPath);
    if (!source.existsSync()) {
      throw StateError('备份文件不存在：$backupPath');
    }
    final targetPath = database.path;
    if (targetPath.isEmpty) {
      throw StateError('数据库尚未打开，无法恢复');
    }
    if (database.isOpen) await database.close();
    await source.copy(targetPath);
    await database.open();
  }

  /// Remote URL of the backup file: `<base>/<remoteDirectory>/<file>`.
  static String remoteBackupUrl(
    String baseUrl, {
    String remoteDirectory = 'animetrace',
    String remoteFileName = 'anime_trace_backup.db',
  }) {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return '$base/$remoteDirectory/$remoteFileName';
  }

  /// Uploads the newest device backup (or a fresh one) to [baseUrl] over
  /// WebDAV. [baseUrl], [user] and [password] come from user input.
  Future<String> uploadToWebDav({
    required String baseUrl,
    required String user,
    required String password,
    DateTime? now,
  }) async {
    final file = await backupToDevice(now: now);
    final remoteFile = remoteBackupUrl(
      baseUrl,
      remoteDirectory: remoteDirectory,
      remoteFileName: remoteFileName,
    );
    final directoryUrl = remoteFile.substring(0, remoteFile.lastIndexOf('/'));
    final options = _authOptions(user, password);
    try {
      await _dio.request<void>(
        directoryUrl,
        data: null,
        options: options.copyWith(method: 'MKCOL'),
      );
    } catch (_) {
      // The collection may already exist (405) or the server may not support
      // MKCOL at all; the PUT below is the real test.
    }
    final bytes = await file.readAsBytes();
    await _dio.put<void>(
      remoteFile,
      data: bytes,
      options: _authOptions(user, password, contentTypeLength: bytes.length),
    );
    return remoteFile;
  }

  /// Downloads the WebDAV backup over [baseUrl] and restores it.
  Future<void> downloadFromWebDav({
    required String baseUrl,
    required String user,
    required String password,
  }) async {
    final remoteFile = remoteBackupUrl(
      baseUrl,
      remoteDirectory: remoteDirectory,
      remoteFileName: remoteFileName,
    );
    final response = await _dio.get<List<int>>(
      remoteFile,
      options: _authOptions(
        user,
        password,
      ).copyWith(responseType: ResponseType.bytes, receiveTimeout: timeout),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('WebDAV 上没有可用的备份');
    }
    final directory = await backupDirectory();
    final local = File(
      '${directory.path}${Platform.pathSeparator}webdav_'
      '${backupFileName(DateTime.now())}',
    );
    await local.writeAsBytes(bytes);
    await restoreFromDevice(local.path);
  }

  Options _authOptions(String user, String password, {int? contentTypeLength}) {
    final headers = <String, Object?>{};
    if (user.isNotEmpty) {
      final token = base64Encode(utf8.encode('$user:$password'));
      headers['Authorization'] = 'Basic $token';
    }
    if (contentTypeLength != null) {
      headers['Content-Length'] = contentTypeLength;
      headers['Content-Type'] = 'application/octet-stream';
    }
    return Options(
      headers: headers,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      validateStatus: (status) => status != null && status < 400,
    );
  }
}
