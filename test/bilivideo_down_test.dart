// Offline tests for the bilivideo_down module.
//
// Nothing here touches the network: the bilibili JSON endpoints answer through
// a fake `HttpClientAdapter` installed on a real `Dio`, the range downloader
// talks to a fake adapter that records every `Range` header and slices a byte
// buffer, and sqflite is served by a method-channel mock (this host does not
// depend on `sqflite_common_ffi`, so no real on-disk sqlite can be opened in a
// `flutter test` process).

import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/movie/bilivideo_down/bili_api.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_api_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_controller.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_format.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_task.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_file_paths.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_play_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_range_downloader.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_stream_selection.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_status.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_store.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_id.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_stream.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

// ---------------------------------------------------------------------------
// Fixtures: shaped after real `api.bilibili.com` replies.
// ---------------------------------------------------------------------------

Map<String, dynamic> viewResponse() => <String, dynamic>{
  'code': 0,
  'message': '0',
  'ttl': 1,
  'data': <String, dynamic>{
    'bvid': 'BV1xx411c7mD',
    'aid': 170001,
    'videos': 2,
    'pic': 'http://i0.hdslb.com/bfs/archive/cover.jpg',
    'title': '测试视频',
    'pubdate': 1590000000,
    'ctime': 1590000100,
    'desc': '这是一个测试视频',
    'duration': 200,
    'dynamic': '测试动态',
    'cid': 123456,
    'season_id': 999,
    'owner': <String, dynamic>{'mid': 42, 'name': 'UP主'},
    'ugc_season': <String, dynamic>{
      'id': 999,
      'title': '测试合集',
      'cover': 'http://i0.hdslb.com/bfs/archive/season.jpg',
      'mid': 42,
      'intro': '合集简介',
      'sign_state': 0,
      'attribute': 1,
      'ep_count': 2,
      'sections': <dynamic>[
        <String, dynamic>{
          'season_id': 999,
          'episodes': <dynamic>[
            <String, dynamic>{
              'aid': 170001,
              'cid': 123456,
              'title': 'P1 上集',
              'bvid': 'BV1xx411c7mD',
              'arc': <String, dynamic>{
                'pic': 'http://i0.hdslb.com/p1.jpg',
                'pubdate': 1590000000,
                'ctime': 1590000100,
              },
            },
            <String, dynamic>{
              'aid': 170002,
              'cid': 123457,
              'title': 'P2 下集',
              'bvid': 'BV1yy411c7mE',
              'arc': <String, dynamic>{
                'pic': 'http://i0.hdslb.com/p2.jpg',
                'pubdate': 1590000200,
                'ctime': 1590000300,
              },
            },
          ],
        },
      ],
    },
  },
};

/// `qn=80&platform=html5` answer: one progressive FLV in `durl`.
Map<String, dynamic> flvResponse() => <String, dynamic>{
  'code': 0,
  'message': '0',
  'ttl': 1,
  'data': <String, dynamic>{
    'from': 'local',
    'quality': 80,
    'format': 'flv720',
    'timelength': 200000,
    'accept_format': 'flv720,flv480,flv360',
    'accept_description': <dynamic>['高清 1080P', '清晰 480P', '流畅 360P'],
    'accept_quality': <dynamic>[80, 32, 16],
    'video_codecid': 7,
    'support_formats': <dynamic>[
      <String, dynamic>{
        'quality': 80,
        'format': 'flv720',
        'new_description': '1080P 高清',
        'display_desc': '1080P',
        'superscript': '',
      },
      <String, dynamic>{
        'quality': 32,
        'format': 'flv480',
        'new_description': '480P 清晰',
        'display_desc': '480P',
        'superscript': '',
      },
    ],
    'durl': <dynamic>[
      <String, dynamic>{
        'order': 1,
        'length': 200000,
        'size': 4096,
        'url': 'https://upos-sz-mirrorcos.bilivideo.com/upgcxcode/1/2/3.flv',
        'backup_url': <dynamic>['https://upos-hz-mirrorakam.akamaized.net/backup.flv'],
      },
    ],
  },
};

/// `fnval` answer: `durl` **and** a DASH block with two video and two audio
/// tracks.
Map<String, dynamic> dashResponse() => <String, dynamic>{
  'code': 0,
  'message': '0',
  'data': <String, dynamic>{
    'quality': 80,
    'format': 'flv720',
    'timelength': 200000,
    'accept_quality': <dynamic>[80, 64, 32],
    'accept_format': 'flv720,flv480,flv360',
    'durl': <dynamic>[
      <String, dynamic>{
        'order': 1,
        'length': 200000,
        'size': 4096,
        'url': 'https://upos.example/flv.flv',
      },
    ],
    'dash': <String, dynamic>{
      'duration': 200.0,
      'minBufferTime': 1.5,
      'video': <dynamic>[
        <String, dynamic>{
          'id': 80,
          'baseUrl': 'https://upos.example/v80.m4s',
          'backupUrl': <dynamic>['https://upos.example/v80-backup.m4s'],
          'bandwidth': 2000000,
          'mimeType': 'video/mp4',
          'codecs': 'avc1.640032',
          'width': 1920,
          'height': 1080,
          'frameRate': '30.000',
          'sar': '1:1',
          'startWithSap': 1,
        },
        <String, dynamic>{
          'id': 64,
          'baseUrl': 'https://upos.example/v64.m4s',
          'bandwidth': 1000000,
          'mimeType': 'video/mp4',
          'codecs': 'avc1.64001f',
          'width': 1280,
          'height': 720,
          'frameRate': '30.000',
          'sar': '1:1',
          'startWithSap': 1,
        },
      ],
      'audio': <dynamic>[
        <String, dynamic>{
          'id': 30280,
          'baseUrl': 'https://upos.example/a128.m4s',
          'bandwidth': 132000,
          'mimeType': 'audio/mp4',
          'codecs': 'mp4a.40.2',
        },
        <String, dynamic>{
          'id': 30232,
          'baseUrl': 'https://upos.example/a64.m4s',
          'bandwidth': 66000,
          'mimeType': 'audio/mp4',
          'codecs': 'mp4a.40.2',
        },
      ],
    },
  },
};

/// Deterministic, non-repeating 1000-byte payload.
Uint8List body(int length) =>
    Uint8List.fromList(List<int>.generate(length, (i) => (i * 31 + 7) % 256));

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Answers JSON with a canned `{code, message, data}` envelope.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.responder);

  final Map<String, dynamic> Function(RequestOptions options) responder;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final bytes = utf8.encode(jsonEncode(responder(options)));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: <String, List<String>>{
        'content-type': <String>['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A byte-range server: records each `Range` header and answers `206` with the
/// requested slice, `200` with the whole body when [ignoreRange] is set, or
/// `500` for the first [failFirstRequests] calls.
class _RangeServer implements HttpClientAdapter {
  _RangeServer({
    required this.body,
    this.deliveryDelay = Duration.zero,
    this.ignoreRange = false,
    this.failFirstRequests = 0,
    this.shortRangeBytes = 0,
  });

  final Uint8List body;
  final Duration deliveryDelay;
  final bool ignoreRange;
  int failFirstRequests;

  /// Test hook: answer a non-probe range with at most this many bytes, the way
  /// a connection that dies mid-body would. `0` disables the truncation.
  final int shortRangeBytes;
  final List<String> rangeHeaders = <String>[];
  final List<String> referers = <String>[];
  final List<int> statuses = <int>[];

  int get requests => rangeHeaders.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (deliveryDelay > Duration.zero) {
      await Future<void>.delayed(deliveryDelay);
    }
    final token = options.cancelToken;
    if (token != null && token.isCancelled) {
      throw DioException.requestCancelled(
        requestOptions: options,
        reason: token.cancelError?.message,
      );
    }
    if (failFirstRequests > 0) {
      failFirstRequests -= 1;
      statuses.add(500);
      rangeHeaders.add('${options.headers['range']}');
      return ResponseBody.fromBytes(
        <int>[],
        500,
        headers: <String, List<String>>{
          'content-type': <String>['text/plain'],
        },
      );
    }
    referers.add('${options.headers['Referer'] ?? options.headers['referer']}');
    final range = options.headers['range'];
    if (range is! String || ignoreRange) {
      rangeHeaders.add('$range');
      statuses.add(200);
      return ResponseBody.fromBytes(
        body,
        200,
        headers: <String, List<String>>{
          'content-length': <String>['${body.length}'],
        },
      );
    }
    rangeHeaders.add(range);
    final match = RegExp(r'bytes=(\d+)-(\d+)').firstMatch(range)!;
    final start = int.parse(match.group(1)!);
    final end = int.parse(match.group(2)!);
    final last = body.length - 1;
    final raw = start > last
        ? Uint8List(0)
        : Uint8List.sublistView(body, start, end > last ? last + 1 : end + 1);
    final slice =
        (shortRangeBytes > 0 && start > 0 && raw.length > shortRangeBytes)
        ? Uint8List.sublistView(raw, 0, shortRangeBytes)
        : raw;
    statuses.add(206);
    return ResponseBody.fromBytes(
      slice,
      206,
      headers: <String, List<String>>{
        'content-length': <String>['${slice.length}'],
        'content-range': <String>['bytes $start-${start + slice.length - 1}/${body.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio dioWith(HttpClientAdapter adapter) {
  final dio = Dio(
    BaseOptions(validateStatus: (int? status) => status != null && status < 600),
  );
  dio.httpClientAdapter = adapter;
  return dio;
}

/// In-memory stand-in for the native sqflite plugin.
///
/// `sqflite` funnels `insert`/`update`/`query`/`delete`/`execute` through one
/// method channel as plain SQL + arguments, so evaluating the handful of
/// statements [BiliTaskStore] issues is enough to exercise it end to end.
class _SqfliteMock {
  static const MethodChannel channel = MethodChannel('com.tekartik.sqflite');

  final Map<String, Map<String, List<Map<String, Object?>>>> _tables =
      <String, Map<String, List<Map<String, Object?>>>>{};
  final Map<String, int> _versions = <String, int>{};
  final Map<String, String> _primaryKeys = <String, String>{};
  final Map<int, String> _handles = <int, String>{};
  final List<String> methods = <String>[];
  int _nextHandle = 1;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, _handle);
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  }

  Future<Object?> _handle(MethodCall call) async {
    methods.add(call.method);
    final args = Map<Object?, Object?>.from(
      call.arguments as Map? ?? const <Object?, Object?>{},
    );
    switch (call.method) {
      case 'openDatabase':
        final path = '${args['path']}';
        _tables.putIfAbsent(path, () => <String, List<Map<String, Object?>>>{});
        _versions.putIfAbsent(path, () => 0);
        final handle = _nextHandle++;
        _handles[handle] = path;
        return handle;
      case 'closeDatabase':
        _handles.remove(args['id']);
        return null;
      case 'execute':
        return _execute(
          _pathOf(args['id']),
          '${args['sql']}',
          _arguments(args),
        );
      case 'insert':
        return _insert(
          _pathOf(args['id']),
          '${args['sql']}',
          _arguments(args),
        );
      case 'query':
        return _query(_pathOf(args['id']), '${args['sql']}', _arguments(args));
      case 'update':
        final sql = '${args['sql']}';
        return sql.trimLeft().toUpperCase().startsWith('DELETE')
            ? _delete(_pathOf(args['id']), sql, _arguments(args))
            : _update(_pathOf(args['id']), sql, _arguments(args));
      case 'getPlatformVersion':
        return 'bilivideo_down_test';
      default:
        throw UnsupportedError('unexpected sqflite method ${call.method}');
    }
  }

  String _pathOf(Object? id) => _handles[id as int] ?? 'memory';

  List<Object?> _arguments(Map<Object?, Object?> args) =>
      (args['arguments'] as List?)?.cast<Object?>() ?? const <Object?>[];

  Object? _execute(String path, String sql, List<Object?> args) {
    final upper = sql.trimLeft().toUpperCase();
    if (upper.startsWith('CREATE TABLE')) {
      final name = RegExp(
        r'CREATE TABLE (?:IF NOT EXISTS )?["`]?(\w+)',
        caseSensitive: false,
      ).firstMatch(sql)!.group(1)!;
      _tables[path]!.putIfAbsent(name, () => <Map<String, Object?>>[]);
      _primaryKeys[name] =
          RegExp(
            r'(?:\(|,)\s*(\w+)\s+\w+[^,]*PRIMARY KEY',
            caseSensitive: false,
          ).firstMatch(sql)?.group(1) ??
          'rowid';
      return null;
    }
    if (upper.startsWith('PRAGMA USER_VERSION')) {
      final set = RegExp(
        r'USER_VERSION\s*=\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(upper);
      if (set != null) _versions[path] = int.parse(set.group(1)!);
      return null;
    }
    if (upper.startsWith('BEGIN') ||
        upper.startsWith('COMMIT') ||
        upper.startsWith('ROLLBACK')) {
      return null;
    }
    if (upper.startsWith('DELETE')) return _delete(path, sql, args);
    if (upper.startsWith('INSERT')) return _insert(path, sql, args);
    if (upper.startsWith('UPDATE')) return _update(path, sql, args);
    throw UnsupportedError('unexecutable sql: $sql');
  }

  List<Map<String, Object?>> _rows(String path, String table) => _tables[path]!
      .putIfAbsent(table, () => <Map<String, Object?>>[]);

  int _insert(String path, String sql, List<Object?> args) {
    final match = RegExp(
      r'INSERT(?:\s+OR\s+\w+)?\s+INTO\s+["`]?(\w+)["`]?\s*\(([^)]*)\)',
      caseSensitive: false,
    ).firstMatch(sql)!;
    final table = match.group(1)!;
    final columns = match
        .group(2)!
        .split(',')
        .map((column) => column.trim().replaceAll(RegExp(r'["`]'), ''))
        .toList();
    final row = <String, Object?>{};
    for (var i = 0; i < columns.length; i++) {
      row[columns[i]] = i < args.length ? args[i] : null;
    }
    final rows = _rows(path, table);
    final key = _primaryKeys[table] ?? 'rowid';
    final index = rows.indexWhere((existing) => existing[key] == row[key]);
    if (index >= 0) {
      rows[index] = row;
      return index + 1;
    }
    rows.add(row);
    return rows.length;
  }

  List<Map<String, Object?>> _query(
    String path,
    String sql,
    List<Object?> args,
  ) {
    final upper = sql.trimLeft().toUpperCase();
    if (upper.startsWith('PRAGMA USER_VERSION')) {
      return <Map<String, Object?>>[
        <String, Object?>{'user_version': _versions[path] ?? 0},
      ];
    }
    final table = RegExp(
      r'FROM\s+["`]?(\w+)',
      caseSensitive: false,
    ).firstMatch(sql)!.group(1)!;
    if (upper.contains('COUNT(*)')) {
      return <Map<String, Object?>>[
        <String, Object?>{'total': _rows(path, table).length},
      ];
    }
    var rows = <Map<String, Object?>>[..._rows(path, table)];
    final where = RegExp(
      r'WHERE\s+(.*?)(?:\s+ORDER BY|\s+LIMIT|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(sql);
    if (where != null) {
      final clause = where.group(1)!.trim();
      final inClause = RegExp(
        r'^(\w+)\s+IN\s*\(([^)]*)\)$',
        caseSensitive: false,
      ).firstMatch(clause);
      if (inClause != null) {
        final column = inClause.group(1)!;
        final wanted = args.toSet();
        rows = rows.where((row) => wanted.contains(row[column])).toList();
      } else {
        final equals = RegExp(r'^(\w+)\s*=\s*\?$').firstMatch(clause);
        if (equals == null) {
          throw UnsupportedError('unsupported WHERE clause: $clause');
        }
        final column = equals.group(1)!;
        rows = rows.where((row) => row[column] == args.first).toList();
      }
    }
    final order = RegExp(
      r'ORDER BY\s+(.*?)(?:\s+LIMIT|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(sql);
    if (order != null) {
      final terms = order.group(1)!.split(',').map((t) => t.trim()).toList();
      rows.sort((a, b) {
        for (final term in terms) {
          final parts = term.split(RegExp(r'\s+'));
          final descending =
              parts.length > 1 && parts[1].toUpperCase() == 'DESC';
          final result = _compare(a[parts.first], b[parts.first]);
          if (result != 0) return descending ? -result : result;
        }
        return 0;
      });
    }
    final limit = RegExp(r'LIMIT\s+(\d+)', caseSensitive: false).firstMatch(sql);
    if (limit != null) {
      final value = int.parse(limit.group(1)!);
      if (rows.length > value) rows = rows.sublist(0, value);
    }
    return rows;
  }

  int _update(String path, String sql, List<Object?> args) {
    final match = RegExp(
      r'UPDATE\s+["`]?(\w+)["`]?\s+SET\s+(.*?)\s+WHERE\s+(.*)$',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(sql)!;
    final table = match.group(1)!;
    final assignments = match.group(2)!.split(',').map((t) => t.trim()).toList();
    var index = 0;
    final values = <String, Object?>{};
    for (final assignment in assignments) {
      values[assignment.split('=').first.trim()] = args[index++];
    }
    final keyColumn = RegExp(
      r'^(\w+)\s*=\s*\?$',
    ).firstMatch(match.group(3)!.trim())!.group(1)!;
    final key = args[index];
    var updated = 0;
    for (final row in _rows(path, table)) {
      if (row[keyColumn] == key) {
        row.addAll(values);
        updated += 1;
      }
    }
    return updated;
  }

  int _delete(String path, String sql, List<Object?> args) {
    final table = RegExp(
      r'DELETE\s+FROM\s+["`]?(\w+)',
      caseSensitive: false,
    ).firstMatch(sql)!.group(1)!;
    final rows = _rows(path, table);
    final where = RegExp(
      r'WHERE\s+(\w+)\s*=\s*\?',
      caseSensitive: false,
    ).firstMatch(sql);
    if (where == null) {
      final removed = rows.length;
      rows.clear();
      return removed;
    }
    final column = where.group(1)!;
    final before = rows.length;
    rows.removeWhere((row) => row[column] == args.first);
    return before - rows.length;
  }

  static int _compare(Object? a, Object? b) {
    if (a == b) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    return '$a'.compareTo('$b');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

late Directory documents;

Directory tempDir(String prefix) {
  final directory = Directory.systemTemp.createTempSync('bilivideo_$prefix');
  addTearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });
  return directory;
}

Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  String reason = 'condition',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for $reason');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Map<String, dynamic> Function(RequestOptions) biliResponder(
  List<String> paths,
) => (RequestOptions options) {
  paths.add(options.uri.path);
  if (options.uri.path == BiliApi.viewPath) return viewResponse();
  if (options.uri.path == BiliApi.playUrlPath) return flvResponse();
  return <String, dynamic>{'code': -404, 'message': '啥都木有', 'data': null};
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _SqfliteMock sqlite;

  setUpAll(() {
    documents = Directory.systemTemp.createTempSync('bilivideo_docs');
    databaseFactoryOrNull ??= databaseFactorySqflitePlugin;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall call) async => call.method == 'getDownloadsDirectory'
              ? null
              : documents.path,
        );
  });

  tearDownAll(() {
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  setUp(() {
    sqlite = _SqfliteMock()..install();
  });

  tearDown(() => sqlite.uninstall());

  group('bilibili JSON fixtures', () {
    test('maps a real-shaped view response including its ugc_season', () {
      final info = BiliVideoInfo.fromJson(
        viewResponse()['data'] as Map<String, dynamic>,
      );
      expect(info.bvid, 'BV1xx411c7mD');
      expect(info.aid, 170001);
      expect(info.cid, 123456);
      expect(info.title, '测试视频');
      expect(info.pic, 'http://i0.hdslb.com/bfs/archive/cover.jpg');
      // `view.duration` is seconds; `durl.length` is milliseconds.
      expect(info.duration, 200);
      expect(info.isCollection, isTrue);
      expect(info.episodes, hasLength(2));
      expect(info.episodes[1].title, 'P2 下集');
      expect(info.episodes[1].cid, 123457);
      expect(info.episodes[1].arc.pic, 'http://i0.hdslb.com/p2.jpg');
      expect(info.ugcSeason!.title, '测试合集');
      expect(info.ugcSeason!.epCount, 2);
      expect(info.primaryCid, 123456);
    });

    test('degrades missing keys instead of throwing', () {
      final info = BiliVideoInfo.fromJson(const <String, dynamic>{});
      expect(info.bvid, '');
      expect(info.aid, 0);
      expect(info.primaryCid, 0);
      expect(info.isCollection, isFalse);
      expect(
        BiliStreamSelection.resolve(
          BiliPlayInfo.fromJson(const <String, dynamic>{}),
        ),
        isNull,
      );
      expect(info.toJson()['title'], '');
    });

    test('maps an FLV play-url response and selects durl[0]', () {
      final play = BiliPlayInfo.fromJson(
        flvResponse()['data'] as Map<String, dynamic>,
      );
      expect(play.quality, 80);
      expect(play.format, 'flv720');
      expect(play.timelength, 200000);
      expect(play.acceptQuality, <int>[80, 32, 16]);
      expect(play.durl, hasLength(1));
      expect(play.hasDashStream, isFalse);
      expect(play.primarySegment!.size, 4096);
      expect(play.primarySegment!.url, contains('upgcxcode'));
      expect(play.supportFormats.first.label, contains('1080P'));

      final selection = BiliStreamSelection.fromPlayInfo(play);
      expect(selection.qualities, <int>[80, 32, 16]);
      expect(selection.formats, <BiliDownloadFormat>[BiliDownloadFormat.flv]);
      expect(selection.defaultQuality, 80);
      expect(selection.defaultFormat, BiliDownloadFormat.flv);
      expect(selection.isEmpty, isFalse);
      expect(BiliStreamSelection.qualityLabel(80), '1080P 高清');
      expect(biliQualityLabel(64), '720P 高清');

      final stream = BiliStreamSelection.resolve(play)!;
      expect(stream.format, BiliDownloadFormat.flv);
      expect(stream.quality, 80);
      expect(stream.url, play.primarySegment!.url);
      expect(stream.size, 4096);
      expect(stream.durationMs, 200000);
      expect(stream.durationText, '03:20');
      expect(stream.hasSeparateAudio, isFalse);
      expect(stream.isSegmented, isFalse);
      expect(formatBytes(stream.size), '4.00KB');
      expect(formatBytes(0), '0B');
    });

    test('selects DASH tracks when the response carries a dash block', () {
      final play = BiliPlayInfo.fromJson(
        dashResponse()['data'] as Map<String, dynamic>,
      );
      expect(play.hasDashStream, isTrue);
      expect(play.dash!.duration, 200.0);
      expect(play.dash!.hasVideo, isTrue);
      expect(play.dash!.hasAudio, isTrue);
      expect(play.dash!.video.first.resolutionLabel, '1920x1080');
      expect(play.dash!.video.first.backupUrl, <String>[
        'https://upos.example/v80-backup.m4s',
      ]);
      expect(BiliStreamSelection.formatsOf(play), <BiliDownloadFormat>[
        BiliDownloadFormat.flv,
        BiliDownloadFormat.dash,
      ]);
      expect(BiliStreamSelection.qualitiesOf(play), <int>[80, 64, 32]);
      expect(BiliStreamSelection.defaultQualityOf(play), 80);
      expect(BiliStreamSelection.pickDashVideo(play.dash!, 64)!.id, 64);
      expect(BiliStreamSelection.pickDashVideo(play.dash!, 60)!.id, 64);
      expect(
        BiliStreamSelection.pickDashAudio(play.dash!)!.baseUrl,
        'https://upos.example/a128.m4s',
      );

      final dash = BiliStreamSelection.resolve(
        play,
        quality: 64,
        format: BiliDownloadFormat.dash,
      )!;
      expect(dash.format, BiliDownloadFormat.dash);
      expect(dash.quality, 64);
      expect(dash.url, 'https://upos.example/v64.m4s');
      expect(dash.audioUrl, 'https://upos.example/a128.m4s');
      expect(dash.hasSeparateAudio, isTrue);
      expect(dash.durationMs, 200000);
      // FLV still wins by default, exactly what the source app downloaded.
      expect(BiliStreamSelection.resolve(play)!.format, BiliDownloadFormat.flv);
      expect(
        const BiliStreamSelection(
          qualities: <int>[],
          formats: <BiliDownloadFormat>[],
          defaultQuality: biliDefaultQuality,
        ).defaultFormat,
        isNull,
      );
      expect(
        const BiliStreamSelection(
          qualities: <int>[],
          formats: <BiliDownloadFormat>[],
          defaultQuality: biliDefaultQuality,
        ).isEmpty,
        isTrue,
      );
    });
  });

  group('BiliVideoId parsing and input validation', () {
    test('parses BV and av ids out of pasted URLs', () {
      final url = BiliVideoId.parse(
        'https://www.bilibili.com/video/BV1xx411c7mD?p=3&spm_id_from=333.999',
      )!;
      expect(url.bvid, 'BV1xx411c7mD');
      expect(url.aid, isNull);
      expect(url.page, 3);
      expect(url.hasBvid, isTrue);
      expect(url.isValid, isTrue);

      final bare = BiliVideoId.parse('BV1xx411c7mD')!;
      expect(bare.bvid, 'BV1xx411c7mD');
      expect(bare.page, 1);

      final av = BiliVideoId.parse('https://www.bilibili.com/video/av170001')!;
      expect(av.bvid, isNull);
      expect(av.aid, 170001);
      expect(av.label, 'av170001');

      final bareAv = BiliVideoId.parse('AV170001')!;
      expect(bareAv.aid, 170001);

      final paged = BiliVideoId.parse(
        'https://www.bilibili.com/video/av170001?p=2',
      )!;
      expect(paged.aid, 170001);
      expect(paged.page, 2);

      // Short links are a redirect service, not a video id.
      expect(BiliVideoId.parse('https://b23.tv/abcdefg'), isNull);
      expect(BiliVideoId.parse('BV123'), isNull);
      expect(BiliVideoId.parse(''), isNull);
      expect(BiliVideoId.parse('https://www.bilibili.com/'), isNull);
    });

    test('validates pasted input without touching the network', () {
      expect(BiliDownloadController.inputError(''), '请输入B站视频链接或BV号');
      expect(BiliDownloadController.inputError('   '), '请输入B站视频链接或BV号');
      expect(
        BiliDownloadController.inputError('随便什么东西'),
        '无法识别的B站视频链接',
      );
      expect(BiliDownloadController.inputError('BV1xx411c7mD'), isNull);
      expect(
        BiliDownloadController.inputError(
          'https://www.bilibili.com/video/BV1xx411c7mD?p=2',
        ),
        isNull,
      );
    });

    test('sanitises titles for the filesystem', () {
      expect(BiliDownloadController.sanitizeFileName('a/b:c*d?e"f<g>h|i'), 'a_b_c_d_e_f_g_h_i');
      expect(BiliDownloadController.sanitizeFileName('  '), 'bili_video');
      expect(BiliDownloadController.sanitizeFileName('测试 视频'), '测试 视频');
      expect(BiliDownloadController.sanitizeFileName('x' * 100).length, 80);
    });
  });

  group('BiliApi request building', () {
    test('sends the source parameters plus bilibili headers', () async {
      final json = _JsonAdapter(biliResponder(<String>[]));
      final api = BiliApi(dioWith(json));

      final play = await api.fetchPlayInfo(
        avid: 170001,
        cid: 123456,
        cookie: 'SESSDATA=abc',
      );
      final request = json.requests.single;
      expect(request.uri.host, 'api.bilibili.com');
      expect(request.uri.path, BiliApi.playUrlPath);
      expect(request.uri.scheme, 'https');
      expect(request.queryParameters, <String, dynamic>{
        'avid': 170001,
        'cid': 123456,
        'qn': 80,
        'platform': 'html5',
        'otype': 'json',
        'high_quality': 1,
      });
      expect(request.queryParameters.containsKey('fnval'), isFalse);
      expect(request.queryParameters.containsKey('fnver'), isFalse);
      expect(request.headers['Referer'], 'https://www.bilibili.com/');
      expect('${request.headers['User-Agent']}', contains('Mozilla/5.0'));
      expect(request.headers['Cookie'], 'SESSDATA=abc');
      expect(play.primarySegment!.size, 4096);
      expect(play.quality, 80);
    });

    test('adds fnval/fnver only when the caller asks for DASH', () {
      expect(BiliApi.playUrlQuery(avid: 1, cid: 2, fnval: 4048, fnver: 0), <String, dynamic>{
        'avid': 1,
        'cid': 2,
        'qn': 80,
        'platform': 'html5',
        'otype': 'json',
        'high_quality': 1,
        'fnval': 4048,
        'fnver': 0,
      });
      expect(BiliApi.defaultHeaders()['Cookie'], isNull);
      expect(BiliApi.defaultHeaders(cookie: '')['Cookie'], isNull);
      expect(BiliApi.viewQuery(bvid: 'BV1xx411c7mD'), <String, dynamic>{
        'bvid': 'BV1xx411c7mD',
      });
      expect(BiliApi.viewQuery(aid: 170001), <String, dynamic>{'aid': 170001});
      expect(BiliApi.absoluteUrl(BiliApi.viewPath), 'https://api.bilibili.com/x/web-interface/view');
      expect(
        BiliApi.absoluteUrl('https://api.bilibili.com/x/player/playurl'),
        'https://api.bilibili.com/x/player/playurl',
      );
    });

    test('fetches video info and surfaces the envelope code', () async {
      final json = _JsonAdapter(biliResponder(<String>[]));
      final api = BiliApi(dioWith(json));
      final info = await api.fetchVideoInfo(bvid: 'BV1xx411c7mD');
      expect(json.requests.single.queryParameters, <String, dynamic>{
        'bvid': 'BV1xx411c7mD',
      });
      expect(info.title, '测试视频');

      final failing = _JsonAdapter(
        (RequestOptions options) =>
            <String, dynamic>{'code': -404, 'message': '啥都木有', 'data': null},
      );
      await expectLater(
        BiliApi(dioWith(failing)).fetchVideoInfo(bvid: 'BV1xx411c7mD'),
        throwsA(
          isA<BiliApiException>()
              .having((e) => e.code, 'code', -404)
              .having((e) => e.message, 'message', '啥都木有'),
        ),
      );
    });
  });

  group('BiliRangeDownloader', () {
    test('probes 102 bytes then downloads maxChunk ranges by byte offset',
        () async {
      final bytes = body(1000);
      final server = _RangeServer(body: bytes);
      final directory = tempDir('ranges');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');
      final progress = <List<int>>[];

      final written = await BiliRangeDownloader(dio: dioWith(server)).download(
        url: 'https://upos.example/video.flv',
        savePath: savePath,
        headers: const <String, String>{'Referer': BiliApi.defaultReferer},
        onProgress: (received, total) => progress.add(<int>[received, total]),
      );

      expect(written, 1000);
      expect(File(savePath).readAsBytesSync(), bytes);
      // 102-byte probe, then ceil(898/2) two-byte-exact tail chunks. The two
      // tail chunks run concurrently, so only the probe's position and the
      // range set are deterministic.
      expect(server.rangeHeaders.first, 'bytes=0-101');
      expect(server.rangeHeaders.toSet(), <String>{
        'bytes=0-101',
        'bytes=102-550',
        'bytes=551-999',
      });
      expect(server.statuses, <int>[206, 206, 206]);
      expect(server.referers, everyElement('https://www.bilibili.com/'));
      expect(progress.last, <int>[1000, 1000]);
      // Temp chunks are merged away.
      expect(File('${savePath}temp0').existsSync(), isFalse);
      expect(File('${savePath}temp1').existsSync(), isFalse);
      expect(File('${savePath}temp2').existsSync(), isFalse);
    });

    test('resumes a partial temp chunk at its byte offset', () async {
      final bytes = body(1000);
      final server = _RangeServer(body: bytes);
      final directory = tempDir('resume');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');
      // A previous run got the leading 102 bytes and 100 bytes of chunk 1.
      File('${savePath}temp0').writeAsBytesSync(bytes.sublist(0, 102));
      File('${savePath}temp1').writeAsBytesSync(bytes.sublist(102, 202));

      final written = await BiliRangeDownloader(dio: dioWith(server)).download(
        url: 'https://upos.example/video.flv',
        savePath: savePath,
      );

      expect(written, 1000);
      expect(File(savePath).readAsBytesSync(), bytes);
      // The probe is awaited first; the two data chunks are requested
      // concurrently, so their wire order is not part of the contract — only
      // their byte ranges are.
      expect(server.rangeHeaders.first, 'bytes=0-101');
      expect(server.rangeHeaders, hasLength(3));
      expect(server.rangeHeaders.toSet(), <String>{
        'bytes=0-101',
        'bytes=202-550',
        'bytes=551-999',
      });
      // The parked prefix was stitched back and cleaned up.
      expect(File('${savePath}temp1_pre').existsSync(), isFalse);
      expect(File('${savePath}temp0').existsSync(), isFalse);
    });

    test('keeps a parked chunk prefix when the tail file was left empty',
        () async {
      final bytes = body(1000);
      final server = _RangeServer(body: bytes);
      final directory = tempDir('resume_pre');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');
      // A previous attempt parked chunk 1's leading 100 bytes and then died
      // before dio wrote the tail, leaving an empty temp1 beside the prefix.
      File('${savePath}temp1').writeAsBytesSync(Uint8List(0));
      File('${savePath}temp1_pre').writeAsBytesSync(bytes.sublist(102, 202));

      final written = await BiliRangeDownloader(dio: dioWith(server)).download(
        url: 'https://upos.example/video.flv',
        savePath: savePath,
      );

      // The parked 100 bytes are reused: neither lost (which would refetch the
      // prefix) nor duplicated (which would make the file 1100 bytes long).
      expect(written, 1000);
      expect(File(savePath).readAsBytesSync(), bytes);
      expect(server.rangeHeaders.toSet(), <String>{
        'bytes=0-101',
        'bytes=202-550',
        'bytes=551-999',
      });
      expect(File('${savePath}temp1_pre').existsSync(), isFalse);
    });

    test('rejects a chunk body shorter than the range it asked for', () async {
      final server = _RangeServer(body: body(1000), shortRangeBytes: 100);
      final directory = tempDir('short');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');

      await expectLater(
        BiliRangeDownloader(dio: dioWith(server)).download(
          url: 'https://upos.example/video.flv',
          savePath: savePath,
        ),
        throwsA(
          isA<BiliDownloadException>().having(
            (e) => '$e',
            'toString',
            contains('ended after'),
          ),
        ),
      );
      // The truncated file is never promoted to the destination, and a retry
      // can still pick the partial chunks up.
      expect(File(savePath).existsSync(), isFalse);
      expect(
        BiliRangeDownloader.deletePartialArtifacts(savePath),
        greaterThan(0),
      );
    });

    test('falls back to a plain download when the server ignores Range',
        () async {
      final bytes = body(1000);
      final server = _RangeServer(body: bytes, ignoreRange: true);
      final directory = tempDir('norange');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');

      final written = await BiliRangeDownloader(dio: dioWith(server)).download(
        url: 'https://upos.example/video.flv',
        savePath: savePath,
      );

      expect(written, 1000);
      expect(File(savePath).readAsBytesSync(), bytes);
      expect(server.requests, 1);
      expect(server.statuses, <int>[200]);
    });

    test('throws BiliDownloadException on an unexpected status code', () async {
      final server = _RangeServer(body: body(10), failFirstRequests: 1);
      final directory = tempDir('status');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');

      await expectLater(
        BiliRangeDownloader(dio: dioWith(server)).download(
          url: 'https://upos.example/video.flv',
          savePath: savePath,
        ),
        throwsA(
          isA<BiliDownloadException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => '$e', 'toString', contains('500')),
        ),
      );
      expect(File(savePath).existsSync(), isFalse);
    });

    test('cancelling aborts in-flight requests and never writes the target',
        () async {
      final server = _RangeServer(
        body: body(1000),
        deliveryDelay: const Duration(milliseconds: 150),
      );
      final directory = tempDir('cancel_downloader');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');
      final token = CancelToken();

      final pending = BiliRangeDownloader(dio: dioWith(server)).download(
        url: 'https://upos.example/video.flv',
        savePath: savePath,
        cancelToken: token,
      );
      // Cancel well inside the probe's 150 ms delivery window, so a request is
      // genuinely in flight when the cancellation lands.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      token.cancel('test');
      await expectLater(
        pending,
        throwsA(isA<BiliDownloadCancelledException>()),
      );

      expect(File(savePath).existsSync(), isFalse);
      expect(server.statuses, isEmpty, reason: 'no response was delivered');
      expect(server.requests, 0, reason: 'aborted before the probe was answered');
      expect(File('${savePath}temp0').existsSync(), isFalse);
    });

    test('deletePartialArtifacts removes temp chunks only', () async {
      final directory = tempDir('artifacts');
      final savePath = BiliFilePaths.join(directory.path, 'video.mp4');
      File(savePath).writeAsBytesSync(<int>[1, 2, 3]);
      File('${savePath}temp0').writeAsBytesSync(<int>[1, 2, 3]);
      File('${savePath}temp1_pre').writeAsBytesSync(<int>[1, 2, 3]);
      File(BiliFilePaths.join(directory.path, 'other.mp4')).writeAsBytesSync(<int>[1]);

      expect(BiliRangeDownloader.deletePartialArtifacts(savePath), 2);
      expect(File(savePath).existsSync(), isTrue);
      expect(File('${savePath}temp0').existsSync(), isFalse);
      expect(File('${savePath}temp1_pre').existsSync(), isFalse);
      expect(File(BiliFilePaths.join(directory.path, 'other.mp4')).existsSync(), isTrue);
    });
  });

  group('BiliTaskStore', () {
    BiliDownloadTask sampleTask({
      String bvid = 'BV1xx411c7mD',
      BiliTaskStatus status = BiliTaskStatus.pending,
      int received = 0,
      DateTime? createdAt,
    }) => BiliDownloadTask(
      bvid: bvid,
      aid: 170001,
      cid: 123456,
      title: '测试视频',
      episodeTitle: 'P1 上集',
      cover: 'http://i0.hdslb.com/bfs/archive/cover.jpg',
      quality: 80,
      format: BiliDownloadFormat.flv,
      status: status,
      receivedBytes: received,
      totalBytes: 2048,
      filePath: '/tmp/测试视频.mp4',
      createdAt: createdAt ?? DateTime(2026, 10, 17, 7),
      updatedAt: createdAt ?? DateTime(2026, 10, 17, 7),
    );

    test('the table DDL covers exactly the mapper columns', () {
      final columns = RegExp(r'(\w+)\s+(?:TEXT|INTEGER)')
          .allMatches(biliTaskCreateTableSql)
          .map((match) => match.group(1)!)
          .toSet();
      expect(columns, sampleTask().toMap().keys.toSet());
      expect(biliTaskTableName, 'bili_download_task');
    });

    test('round-trips a task, updates progress and survives a restart',
        () async {
      final store = BiliTaskStore(fileName: 'store_roundtrip.db');
      final task = sampleTask();
      expect(await store.upsert(task), greaterThan(0));
      expect(await store.count(), 1);
      expect(await store.exists('BV1xx411c7mD'), isTrue);
      expect(await store.exists('BV1yy411c7mE'), isFalse);

      final loaded = (await store.queryAll()).single;
      expect(loaded.bvid, 'BV1xx411c7mD');
      expect(loaded.aid, 170001);
      expect(loaded.cid, 123456);
      expect(loaded.title, '测试视频');
      expect(loaded.episodeTitle, 'P1 上集');
      expect(loaded.quality, 80);
      expect(loaded.format, BiliDownloadFormat.flv);
      expect(loaded.status, BiliTaskStatus.pending);
      expect(loaded.totalBytes, 2048);
      expect(loaded.filePath, '/tmp/测试视频.mp4');
      expect(loaded.createdAt, DateTime(2026, 10, 17, 7));
      expect(loaded.progressLabel, '0B / 2.00KB');

      await store.updateProgress(
        bvid: 'BV1xx411c7mD',
        receivedBytes: 1024,
        totalBytes: 2048,
        status: BiliTaskStatus.downloading,
        updatedAt: DateTime(2026, 10, 17, 8),
      );
      final updated = (await store.queryByBvid('BV1xx411c7mD'))!;
      expect(updated.receivedBytes, 1024);
      expect(updated.status, BiliTaskStatus.downloading);
      expect(updated.progress, 0.5);
      expect(updated.progressLabel, '1024.00B / 2.00KB');
      expect(updated.updatedAt, DateTime(2026, 10, 17, 8));

      await store.close();
      // "Restart": a brand new store over the same file sees the row.
      final reopened = BiliTaskStore(fileName: 'store_roundtrip.db');
      addTearDown(reopened.close);
      final afterRestart = (await reopened.queryAll()).single;
      expect(afterRestart.receivedBytes, 1024);
      expect(afterRestart.status, BiliTaskStatus.downloading);
    });

    test('marks completion and splits completed from resumable', () async {
      final store = BiliTaskStore(fileName: 'store_filters.db');
      addTearDown(store.close);
      await store.upsert(sampleTask(bvid: 'BV1xx411c7mD'));
      await store.upsert(
        sampleTask(
          bvid: 'BV1yy411c7mE',
          createdAt: DateTime(2026, 10, 17, 9),
        ),
      );

      expect(
        (await store.queryAll()).map((task) => task.bvid).toList(),
        <String>['BV1yy411c7mE', 'BV1xx411c7mD'],
      );
      await store.markCompleted(
        bvid: 'BV1xx411c7mD',
        filePath: '/tmp/done.mp4',
        totalBytes: 1000,
        updatedAt: DateTime(2026, 10, 17, 10),
      );
      final completed = await store.queryCompleted();
      expect(completed, hasLength(1));
      expect(completed.single.bvid, 'BV1xx411c7mD');
      expect(completed.single.status, BiliTaskStatus.completed);
      expect(completed.single.isCompleted, isTrue);
      expect(completed.single.receivedBytes, 1000);
      expect(completed.single.filePath, '/tmp/done.mp4');

      final resumable = await store.queryResumable();
      expect(resumable.map((task) => task.bvid).toList(), <String>[
        'BV1yy411c7mE',
      ]);

      await store.updateStatus(
        bvid: 'BV1yy411c7mE',
        status: BiliTaskStatus.failed,
        errorMessage: '网络连接失败',
        updatedAt: DateTime(2026, 10, 17, 11),
      );
      expect(
        (await store.queryByBvid('BV1yy411c7mE'))!.errorMessage,
        '网络连接失败',
      );

      expect(await store.deleteByBvid('BV1yy411c7mE'), 1);
      expect(await store.count(), 1);
      expect(await store.clear(), 1);
      expect(await store.count(), 0);
    });
  });

  group('BiliDownloadController', () {
    test('resolves a video, lists its parts and flags DASH-only streams',
        () async {
      final paths = <String>[];
      final json = _JsonAdapter(biliResponder(paths));
      final controller = BiliDownloadController(
        api: BiliApi(dioWith(json)),
        store: BiliTaskStore(fileName: 'resolve.db'),
        downloader: BiliRangeDownloader(dio: dioWith(_RangeServer(body: body(10)))),
        storageDirectory: () async => tempDir('resolve_storage').path,
        now: () => DateTime(2026, 10, 17, 7),
      );
      addTearDown(controller.dispose);
      await controller.loadTasks();
      expect(controller.tasks, isEmpty);

      expect(await controller.resolve('随便什么东西'), isFalse);
      expect(controller.errorMessage, '无法识别的B站视频链接');

      expect(
        await controller.resolve('https://www.bilibili.com/video/BV1xx411c7mD'),
        isTrue,
      );
      expect(paths, <String>[BiliApi.viewPath, BiliApi.playUrlPath]);
      expect(controller.errorMessage, isNull);
      expect(controller.videoInfo!.title, '测试视频');
      expect(controller.hasVideo, isTrue);
      expect(controller.hasCollection, isTrue);
      expect(controller.episodes, hasLength(2));
      expect(controller.selectedEpisode!.title, 'P1 上集');
      expect(controller.selectedQuality, 80);
      expect(controller.selectedFormat, BiliDownloadFormat.flv);
      expect(controller.selection!.qualities, <int>[80, 32, 16]);
    });

    test('a completed download is persisted and the file is on disk', () async {
      final bytes = body(1000);
      final json = _JsonAdapter(biliResponder(<String>[]));
      final store = BiliTaskStore(fileName: 'complete.db');
      addTearDown(store.close);
      final storage = tempDir('complete_storage');
      final controller = BiliDownloadController(
        api: BiliApi(dioWith(json)),
        store: store,
        downloader: BiliRangeDownloader(dio: dioWith(_RangeServer(body: bytes))),
        storageDirectory: () async => storage.path,
        now: () => DateTime(2026, 10, 17, 7),
      );
      addTearDown(controller.dispose);
      await controller.loadTasks();
      await controller.resolve('BV1xx411c7mD');

      final completed = await controller.startDownload();
      expect(completed, isNotNull);
      final bvid = completed!.bvid;
      final file = File(completed.filePath);
      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync(), bytes);
      expect(completed.filePath, endsWith('测试视频_P1 上集_q80.mp4'));
      expect(completed.bvidKey, bvid);

      expect(controller.isDownloading(bvid), isFalse);
      expect(controller.taskOf(bvid)!.status, BiliTaskStatus.completed);
      expect(controller.completedTasks.map((task) => task.bvid).toList(), <String>[
        bvid,
      ]);
      expect(controller.activeTasks, isEmpty);
      expect(controller.progressOf(bvid), 1.0);
      expect(controller.receivedBytesOf(bvid), 1000);
      expect(controller.notice, contains('下载完成'));

      final row = (await store.queryByBvid(bvid))!;
      expect(row.status, BiliTaskStatus.completed);
      expect(row.totalBytes, 1000);
      expect(row.receivedBytes, 1000);
      expect(row.filePath, completed.filePath);
      expect(await store.count(), 1);
    });

    test('a failed download keeps its row and resumes to completion', () async {
      final bytes = body(1000);
      final json = _JsonAdapter(biliResponder(<String>[]));
      final store = BiliTaskStore(fileName: 'failure.db');
      addTearDown(store.close);
      final server = _RangeServer(body: bytes, failFirstRequests: 1);
      final controller = BiliDownloadController(
        api: BiliApi(dioWith(json)),
        store: store,
        downloader: BiliRangeDownloader(dio: dioWith(server)),
        storageDirectory: () async => tempDir('failure_storage').path,
        now: () => DateTime(2026, 10, 17, 7),
      );
      addTearDown(controller.dispose);
      await controller.loadTasks();
      await controller.resolve('BV1xx411c7mD');

      final failed = await controller.startDownload();
      final bvid = failed!.bvid;
      expect(controller.taskOf(bvid)!.status, BiliTaskStatus.failed);
      expect(controller.taskOf(bvid)!.errorMessage, contains('500'));
      expect(controller.errorMessage, contains('500'));
      expect(controller.completedTasks, isEmpty);
      expect(File(failed.filePath).existsSync(), isFalse);

      await controller.resumeDownload(bvid);
      expect(controller.taskOf(bvid)!.status, BiliTaskStatus.completed);
      expect(File(failed.filePath).readAsBytesSync(), bytes);
      expect(server.rangeHeaders.first, 'bytes=0-101');
      expect(server.statuses.first, 500);
      expect(await store.count(), 1);
    });

    test('pausing keeps the row and never marks the task complete', () async {
      final json = _JsonAdapter(biliResponder(<String>[]));
      final store = BiliTaskStore(fileName: 'pause.db');
      addTearDown(store.close);
      final server = _RangeServer(
        body: body(1000),
        deliveryDelay: const Duration(milliseconds: 300),
      );
      final controller = BiliDownloadController(
        api: BiliApi(dioWith(json)),
        store: store,
        downloader: BiliRangeDownloader(dio: dioWith(server)),
        storageDirectory: () async => tempDir('pause_storage').path,
        now: () => DateTime(2026, 10, 17, 7),
      );
      addTearDown(controller.dispose);
      await controller.loadTasks();
      await controller.resolve('BV1xx411c7mD');

      final pending = controller.startDownload();
      await waitUntil(
        () => controller.isDownloading('BV1xx411c7mD'),
        reason: 'the download to start',
      );
      final task = controller.taskOf('BV1xx411c7mD')!;
      await controller.pauseDownload('BV1xx411c7mD');
      await pending;

      expect(controller.isDownloading('BV1xx411c7mD'), isFalse);
      final paused = controller.taskOf('BV1xx411c7mD')!;
      expect(paused.status, BiliTaskStatus.paused);
      expect(paused.status.isResumable, isTrue);
      expect(controller.completedTasks, isEmpty);
      expect(File(task.filePath).existsSync(), isFalse);
      expect(await store.exists('BV1xx411c7mD'), isTrue);
      expect((await store.queryByBvid('BV1xx411c7mD'))!.status, BiliTaskStatus.paused);
    });

    test('cancelling aborts the task, forgets its row and drops its temp files',
        () async {
      final json = _JsonAdapter(biliResponder(<String>[]));
      final store = BiliTaskStore(fileName: 'cancel.db');
      addTearDown(store.close);
      final server = _RangeServer(
        body: body(1000),
        deliveryDelay: const Duration(milliseconds: 300),
      );
      final controller = BiliDownloadController(
        api: BiliApi(dioWith(json)),
        store: store,
        downloader: BiliRangeDownloader(dio: dioWith(server)),
        storageDirectory: () async => tempDir('cancel_storage').path,
        now: () => DateTime(2026, 10, 17, 7),
      );
      addTearDown(controller.dispose);
      await controller.loadTasks();
      await controller.resolve('BV1xx411c7mD');

      final pending = controller.startDownload();
      await waitUntil(
        () => controller.isDownloading('BV1xx411c7mD'),
        reason: 'the download to start',
      );
      final task = controller.taskOf('BV1xx411c7mD')!;
      await controller.cancelDownload('BV1xx411c7mD');
      await pending;

      expect(controller.isDownloading('BV1xx411c7mD'), isFalse);
      expect(controller.taskOf('BV1xx411c7mD'), isNull);
      expect(controller.tasks, isEmpty);
      expect(controller.completedTasks, isEmpty);
      expect(controller.progressOf('BV1xx411c7mD'), 0);
      expect(await store.exists('BV1xx411c7mD'), isFalse);
      expect(await store.count(), 0);
      expect(File(task.filePath).existsSync(), isFalse);
      expect(File('${task.filePath}temp0').existsSync(), isFalse);
      expect(File('${task.filePath}temp1_pre').existsSync(), isFalse);
    });
  });
}
