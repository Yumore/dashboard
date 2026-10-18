// Network-free tests for the youtubedl module.
//
// All JSON fixtures below are hand-written from the documented InnerTube
// response shape; nothing here contacts YouTube. Dio is driven through a fake
// HttpClientAdapter and the download queue through an in-memory sink, so the
// suite never opens a socket or writes a file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/movie/youtubedl/dio_youtubedl_stream_provider.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_api_endpoints.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_audio_only_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_bytes.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_cancellation_token.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_plan.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_queue.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_status.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_task.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_tile.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_duration.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_file_name.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_muxed_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_page.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_player_response_parser.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_player_result.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_progress.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_page.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_parser.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_container.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_filter.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_provider.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_sink.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_type.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video_only_stream_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Hand-written fixtures
// ---------------------------------------------------------------------------

/// One `formats` / `adaptiveFormats` entry.
Map<String, dynamic> _format({
  required int itag,
  required String mimeType,
  required int bitrate,
  String? contentLength,
  String? url,
  String? qualityLabel,
  int? width,
  int? height,
  int? fps,
  int? audioChannels,
  String? signatureCipher,
}) {
  return <String, dynamic>{
    'itag': itag,
    'mimeType': mimeType,
    'bitrate': bitrate,
    'contentLength': ?contentLength,
    'url': ?url,
    'qualityLabel': ?qualityLabel,
    'width': ?width,
    'height': ?height,
    'fps': ?fps,
    'audioChannels': ?audioChannels,
    'signatureCipher': ?signatureCipher,
  };
}

/// A `player` response with 2 muxed, 2 video-only, 2 audio-only and 1
/// signature-cipher-only format (the last one must be skipped).
Map<String, dynamic> _playerResponse() {
  return <String, dynamic>{
    'playabilityStatus': <String, dynamic>{'status': 'OK'},
    'videoDetails': <String, dynamic>{
      'videoId': 'dQw4w9WgXcQ',
      'title': 'Never Gonna Give You Up',
      'author': 'Rick Astley',
      'lengthSeconds': '213',
      'thumbnail': <String, dynamic>{
        'thumbnails': <Map<String, dynamic>>[
          <String, dynamic>{
            'url': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/default.jpg',
            'width': 120,
            'height': 90,
          },
          <String, dynamic>{
            'url': '//i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
            'width': 480,
            'height': 360,
          },
        ],
      },
    },
    'streamingData': <String, dynamic>{
      'formats': <Map<String, dynamic>>[
        _format(
          itag: 18,
          mimeType: 'video/mp4; codecs="avc1.42001E, mp4a.40.2"',
          bitrate: 1000000,
          contentLength: '7345678',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=18',
          qualityLabel: '360p',
          width: 640,
          height: 360,
          fps: 30,
          audioChannels: 2,
        ),
        _format(
          itag: 22,
          mimeType: 'video/mp4; codecs="avc1.64001F, mp4a.40.2"',
          bitrate: 2500000,
          contentLength: '23456789',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=22',
          qualityLabel: '720p',
          width: 1280,
          height: 720,
          fps: 30,
          audioChannels: 2,
        ),
      ],
      'adaptiveFormats': <Map<String, dynamic>>[
        _format(
          itag: 137,
          mimeType: 'video/mp4; codecs="avc1.640028"',
          bitrate: 4500000,
          contentLength: '104857600',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=137',
          qualityLabel: '1080p',
          width: 1920,
          height: 1080,
          fps: 30,
        ),
        _format(
          itag: 248,
          mimeType: 'video/webm; codecs="vp9"',
          bitrate: 3000000,
          contentLength: '90000000',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=248',
          qualityLabel: '1080p60',
          width: 1920,
          height: 1080,
          fps: 60,
        ),
        _format(
          itag: 140,
          mimeType: 'audio/mp4; codecs="mp4a.40.2"',
          bitrate: 128000,
          contentLength: '3456789',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=140',
          audioChannels: 2,
        ),
        _format(
          itag: 251,
          mimeType: 'audio/webm; codecs="opus"',
          bitrate: 160000,
          contentLength: '4000000',
          url: 'https://rr1.googlevideo.com/videoplayback?itag=251',
          audioChannels: 2,
        ),
        _format(
          itag: 136,
          mimeType: 'video/mp4; codecs="avc1.4d401f"',
          bitrate: 2000000,
          contentLength: '80000000',
          signatureCipher:
              's=ABCDEFG&sp=sig&url=https%3A%2F%2Frr1.googlevideo.com%2Fvideoplayback%3Fitag%3D136',
          qualityLabel: '720p',
          width: 1280,
          height: 720,
          fps: 30,
        ),
      ],
    },
  };
}

Map<String, dynamic> _renderer({
  required String videoId,
  required String title,
  required String author,
  String? lengthText,
  bool live = false,
}) {
  return <String, dynamic>{
    'videoId': videoId,
    'title': <String, dynamic>{
      'runs': <Map<String, dynamic>>[
        <String, dynamic>{'text': title},
      ],
    },
    'ownerText': <String, dynamic>{
      'runs': <Map<String, dynamic>>[
        <String, dynamic>{'text': author},
      ],
    },
    if (lengthText != null)
      'lengthText': <String, dynamic>{'simpleText': lengthText},
    'thumbnail': <String, dynamic>{
      'thumbnails': <Map<String, dynamic>>[
        <String, dynamic>{
          'url': 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
          'width': 480,
          'height': 360,
        },
      ],
    },
    if (live)
      'badges': <Map<String, dynamic>>[
        <String, dynamic>{
          'metadataBadgeRenderer': <String, dynamic>{
            'style': 'BADGE_STYLE_TYPE_LIVE_NOW',
            'label': 'LIVE',
          },
        },
      ],
  };
}

/// A `search` response with two playable videos, one live result and a
/// continuation token nested under `continuationItemRenderer`.
Map<String, dynamic> _searchResponse() {
  return <String, dynamic>{
    'contents': <String, dynamic>{
      'twoColumnSearchResultsRenderer': <String, dynamic>{
        'primaryContents': <String, dynamic>{
          'sectionListRenderer': <String, dynamic>{
            'contents': <Map<String, dynamic>>[
              <String, dynamic>{
                'itemSectionRenderer': <String, dynamic>{
                  'contents': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'videoRenderer': _renderer(
                        videoId: 'vid00000001',
                        title: 'Flutter 下载器教程',
                        author: '示例频道 A',
                        lengthText: '12:34',
                      ),
                    },
                    <String, dynamic>{
                      'videoRenderer': _renderer(
                        videoId: 'vid00000002',
                        title: '教程：1 小时合集',
                        author: '示例频道 B',
                        lengthText: '1:02:03',
                      ),
                    },
                    <String, dynamic>{
                      'videoRenderer': _renderer(
                        videoId: 'live0000001',
                        title: '正在直播',
                        author: '直播频道',
                        live: true,
                      ),
                    },
                  ],
                },
              },
              <String, dynamic>{
                'continuationItemRenderer': <String, dynamic>{
                  'continuationEndpoint': <String, dynamic>{
                    'continuationCommand': <String, dynamic>{
                      'token': 'CONT_TOKEN_1',
                      'request': 'CONTINUATION_REQUEST_TYPE_SEARCH',
                    },
                  },
                },
              },
            ],
          },
        },
      },
    },
  };
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this.respond);

  final FutureOr<ResponseBody> Function(RequestOptions options) respond;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object payload) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

Dio _dioWith(_FakeHttpAdapter adapter) {
  return Dio(BaseOptions(validateStatus: (_) => true))
    ..httpClientAdapter = adapter;
}

class _WriteCall {
  _WriteCall({
    required this.url,
    required this.path,
    required this.totalBytes,
    required this.cancellation,
    required this.onProgress,
  });

  final Uri url;
  final String path;
  final int totalBytes;
  final YoutubeDlCancellationToken cancellation;
  final void Function(int received) onProgress;
}

class _RecordingSink implements YoutubeDlStreamSink {
  _RecordingSink({this.handler, Set<String>? files})
    : files = files ?? <String>{};

  final Future<void> Function(_WriteCall call)? handler;
  final Set<String> files;
  final List<_WriteCall> writes = <_WriteCall>[];
  final List<String> deletions = <String>[];

  @override
  Future<void> write({
    required Uri url,
    required String path,
    required int totalBytes,
    required YoutubeDlCancellationToken cancellation,
    required void Function(int received) onProgress,
  }) async {
    final call = _WriteCall(
      url: url,
      path: path,
      totalBytes: totalBytes,
      cancellation: cancellation,
      onProgress: onProgress,
    );
    writes.add(call);
    final onWrite = handler;
    if (onWrite != null) {
      await onWrite(call);
      return;
    }
    files.add(path);
    onProgress(totalBytes);
  }

  @override
  Future<bool> exists(String path) async => files.contains(path);

  @override
  Future<void> delete(String path) async {
    deletions.add(path);
    files.remove(path);
  }
}

String Function() _ids() {
  var next = 0;
  return () => 'task-${++next}';
}

YoutubeDlDownloadQueue _queueFor(_RecordingSink sink, {int maxConcurrent = 1}) {
  return YoutubeDlDownloadQueue(
    sink: sink,
    downloadDirectory: () async => '/downloads',
    now: () => DateTime(2026, 1, 1),
    idFactory: _ids(),
    maxConcurrent: maxConcurrent,
  );
}

YoutubeDlVideo _video({String id = 'vid1', String title = 'A/B: Test'}) {
  return YoutubeDlVideo(
    id: id,
    title: title,
    author: 'Author',
    duration: const Duration(seconds: 60),
    thumbnail: '',
  );
}

YoutubeDlMuxedStreamInfo _muxed({
  int itag = 18,
  int size = 1000,
  String url = 'https://cdn.example.com/v18',
}) {
  return YoutubeDlMuxedStreamInfo(
    itag: itag,
    url: Uri.parse(url),
    container: YoutubeDlStreamContainer.mp4,
    bitrate: 500000,
    size: size,
    mimeType: 'video/mp4; codecs="avc1, mp4a"',
    codecs: 'avc1, mp4a',
    qualityLabel: '360p',
    height: 360,
    fps: 30,
    videoCodec: 'avc1',
    audioCodec: 'mp4a',
  );
}

YoutubeDlVideoOnlyStreamInfo _videoOnly({
  int size = 2000,
  String url = 'https://cdn.example.com/v137',
}) {
  return YoutubeDlVideoOnlyStreamInfo(
    itag: 137,
    url: Uri.parse(url),
    container: YoutubeDlStreamContainer.mp4,
    bitrate: 4000000,
    size: size,
    mimeType: 'video/mp4; codecs="avc1"',
    codecs: 'avc1',
    qualityLabel: '1080p',
    height: 1080,
    fps: 30,
    videoCodec: 'avc1',
  );
}

YoutubeDlAudioOnlyStreamInfo _audioOnly({
  int size = 500,
  String url = 'https://cdn.example.com/a140',
}) {
  return YoutubeDlAudioOnlyStreamInfo(
    itag: 140,
    url: Uri.parse(url),
    container: YoutubeDlStreamContainer.m4a,
    bitrate: 128000,
    size: size,
    mimeType: 'audio/mp4; codecs="mp4a"',
    codecs: 'mp4a',
    qualityLabel: '128 kbps',
    audioCodec: 'mp4a',
    channels: 2,
  );
}

class _UnusedProvider implements YouTubeStreamProvider {
  @override
  Future<YoutubeDlPlayerResult> loadPlayer(String videoId) {
    throw UnimplementedError();
  }

  @override
  Future<YoutubeDlSearchPage> searchVideos(
    String query, {
    String? continuation,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> suggestions(String query) {
    throw UnimplementedError();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InnerTube endpoints', () {
    test('player URL carries the public key and prettyPrint=false', () {
      expect(
        YoutubeDlApiEndpoints.player('dQw4w9WgXcQ').toString(),
        'https://www.youtube.com/youtubei/v1/player'
        '?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false',
      );
    });

    test('search URL uses the same InnerTube host and key', () {
      expect(
        YoutubeDlApiEndpoints.search().toString(),
        'https://www.youtube.com/youtubei/v1/search'
        '?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false',
      );
    });

    test('suggestions URL encodes spaces as + and keeps parameter order', () {
      expect(
        YoutubeDlApiEndpoints.suggestions('flutter dart').toString(),
        'https://suggestqueries.google.com/complete/search'
        '?client=firefox&ds=yt&q=flutter+dart',
      );
    });

    test('player body carries WEB context and both check flags', () {
      expect(YoutubeDlApiEndpoints.playerBody('abc123'), <String, dynamic>{
        'context': <String, dynamic>{
          'client': <String, dynamic>{
            'clientName': 'WEB',
            'clientVersion': '2.20241010.00.00',
            'hl': 'en',
            'gl': 'US',
          },
        },
        'videoId': 'abc123',
        'contentCheckOk': true,
        'racyCheckOk': true,
      });
    });

    test('search body uses query on the first page and continuation later', () {
      final first = YoutubeDlApiEndpoints.searchBody('flutter');
      expect(first['query'], 'flutter');
      expect(first.containsKey('continuation'), isFalse);

      final next = YoutubeDlApiEndpoints.searchBody(
        '',
        continuation: 'CONT_TOKEN_1',
      );
      expect(next.containsKey('query'), isFalse);
      expect(next['continuation'], 'CONT_TOKEN_1');
    });
  });

  group('containers', () {
    test('MIME types map to the source container names', () {
      expect(
        YoutubeDlStreamContainer.fromMimeType('audio/mp4; codecs="mp4a.40.2"'),
        YoutubeDlStreamContainer.m4a,
      );
      expect(
        YoutubeDlStreamContainer.fromMimeType('audio/webm; codecs="opus"'),
        YoutubeDlStreamContainer.webm,
      );
      expect(
        YoutubeDlStreamContainer.fromMimeType('video/mp4; codecs="avc1"'),
        YoutubeDlStreamContainer.mp4,
      );
      expect(
        YoutubeDlStreamContainer.fromMimeType('video/webm; codecs="vp9"'),
        YoutubeDlStreamContainer.webm,
      );
      expect(
        YoutubeDlStreamContainer.fromMimeType('application/octet-stream'),
        YoutubeDlStreamContainer.unknown,
      );
      expect(YoutubeDlStreamContainer.m4a.extension, 'm4a');
      expect(YoutubeDlStreamContainer.unknown.extension, 'bin');
      expect(YoutubeDlStreamContainer.webm.label, 'WebM');
    });
  });

  group('player response mapping', () {
    late YoutubeDlPlayerResult result;

    setUp(() {
      result = const YoutubeDlPlayerResponseParser().parse(_playerResponse());
    });

    test('video details map to the source QueryVideo fields', () {
      final video = result.video;
      expect(video.id, 'dQw4w9WgXcQ');
      expect(video.title, 'Never Gonna Give You Up');
      expect(video.author, 'Rick Astley');
      expect(video.duration, const Duration(seconds: 213));
      expect(video.durationLabel, '03:33');
      expect(
        video.thumbnail,
        'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
      expect(video.watchUrl, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });

    test('signatureCipher-only formats are skipped and counted', () {
      expect(result.manifest.unavailableCount, 1);
      expect(result.manifest.all.length, 6);
      expect(
        result.manifest.all.map((stream) => stream.itag),
        isNot(contains(136)),
      );
    });

    test('muxed formats are sorted by height descending', () {
      expect(result.manifest.muxed.map((stream) => stream.itag), <int>[22, 18]);
      final first = result.manifest.muxed.first;
      expect(first.qualityLabel, '720p');
      expect(first.height, 720);
      expect(first.videoCodec, 'avc1.64001F');
      expect(first.audioCodec, 'mp4a.40.2');
      expect(first.size, 23456789);
      expect(first.container, YoutubeDlStreamContainer.mp4);
    });

    test('video-only formats order height, then fps, then bitrate', () {
      expect(result.manifest.videoOnly.map((stream) => stream.itag), <int>[
        248,
        137,
      ]);
      expect(result.manifest.videoOnly.first.fps, 60);
      expect(result.manifest.videoOnly.first.height, 1080);
      expect(
        result.manifest.videoOnly.first.container,
        YoutubeDlStreamContainer.webm,
      );
    });

    test('audio-only formats order by bitrate and get kbps labels', () {
      expect(result.manifest.audioOnly.map((stream) => stream.itag), <int>[
        251,
        140,
      ]);
      expect(result.manifest.audioOnly.first.bitrate, 160000);
      expect(result.manifest.audioOnly.first.qualityLabel, '160 kbps');
      expect(result.manifest.audioOnly.last.qualityLabel, '128 kbps');
      expect(result.manifest.audioOnly.last.channels, 2);
    });

    test('all streams are grouped muxed, video-only, audio-only', () {
      expect(result.manifest.all.map((stream) => stream.itag), <int>[
        22,
        18,
        248,
        137,
        251,
        140,
      ]);
      expect(result.manifest.bestMuxed!.itag, 22);
      expect(result.manifest.bestVideoOnly!.itag, 248);
      expect(result.manifest.bestAudioOnly!.itag, 251);
    });

    test('stream filter groups match the source filter tabs', () {
      expect(
        result.manifest.filter(YoutubeDlStreamFilter.videoAudio).length,
        2,
      );
      expect(result.manifest.filter(YoutubeDlStreamFilter.videoOnly).length, 2);
      expect(result.manifest.filter(YoutubeDlStreamFilter.audioOnly).length, 2);
      expect(result.manifest.filter(YoutubeDlStreamFilter.all).length, 6);
      expect(YoutubeDlStreamFilter.audioOnly.label, '仅音频');
    });

    test('unplayable responses throw with the YouTube reason', () {
      final json = _playerResponse();
      json['playabilityStatus'] = <String, dynamic>{
        'status': 'LOGIN_REQUIRED',
        'reason': 'Sign in to confirm you are not a bot',
      };
      expect(
        () => const YoutubeDlPlayerResponseParser().parse(json),
        throwsA(
          isA<YoutubeDlStreamException>().having(
            (error) => error.message,
            'message',
            'Sign in to confirm you are not a bot',
          ),
        ),
      );
    });
  });

  group('search response mapping', () {
    test('renderers map to results and live items are filtered', () {
      final page = const YoutubeDlSearchParser().parse(_searchResponse());
      expect(page.items.length, 2);
      expect(page.continuation, 'CONT_TOKEN_1');
      expect(page.hasMore, isTrue);
      expect(page.items.map((item) => item.videoId), <String>[
        'vid00000001',
        'vid00000002',
      ]);
      expect(page.items.first.author, '示例频道 A');
      expect(page.items.first.duration, const Duration(seconds: 754));
      expect(page.items.first.durationLabel, '12:34');
      expect(page.items.first.thumbnail, contains('vid00000001'));
      expect(page.items.last.duration, const Duration(seconds: 3723));
      expect(page.items.last.durationLabel, '1:02:03');
    });

    test('search without continuation reports no more pages', () {
      final page = const YoutubeDlSearchParser().parse(<String, dynamic>{
        'contents': <String, dynamic>{
          'itemSectionRenderer': <String, dynamic>{
            'contents': <Map<String, dynamic>>[
              <String, dynamic>{
                'videoRenderer': _renderer(
                  videoId: 'only1',
                  title: 'Only',
                  author: 'A',
                  lengthText: '0:05',
                ),
              },
            ],
          },
        },
      });
      expect(page.items.length, 1);
      expect(page.continuation, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('DioYouTubeStreamProvider', () {
    test('loadPlayer posts the player body and parses the manifest', () async {
      final adapter = _FakeHttpAdapter(
        (options) => _jsonBody(_playerResponse()),
      );
      final provider = DioYouTubeStreamProvider(dio: _dioWith(adapter));

      final result = await provider.loadPlayer('dQw4w9WgXcQ');

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(
        request.uri.toString(),
        YoutubeDlApiEndpoints.player('dQw4w9WgXcQ').toString(),
      );
      expect(request.contentType, Headers.jsonContentType);
      expect(request.data, YoutubeDlApiEndpoints.playerBody('dQw4w9WgXcQ'));
      expect(result.video.id, 'dQw4w9WgXcQ');
      expect(result.manifest.muxed.length, 2);
    });

    test('searchVideos posts a query first and a continuation later', () async {
      final adapter = _FakeHttpAdapter(
        (options) => _jsonBody(_searchResponse()),
      );
      final provider = DioYouTubeStreamProvider(dio: _dioWith(adapter));

      final first = await provider.searchVideos('flutter');
      final second = await provider.searchVideos(
        '',
        continuation: 'CONT_TOKEN_1',
      );

      expect(adapter.requests.length, 2);
      expect(adapter.requests.first.method, 'POST');
      expect(adapter.requests.first.uri.path, '/youtubei/v1/search');
      expect(
        adapter.requests.first.data,
        YoutubeDlApiEndpoints.searchBody('flutter'),
      );
      expect(
        adapter.requests.last.data,
        YoutubeDlApiEndpoints.searchBody('', continuation: 'CONT_TOKEN_1'),
      );
      expect(first.items.length, 2);
      expect(second.items.length, 2);
    });

    test(
      'suggestions GET returns the second JSON element as strings',
      () async {
        final adapter = _FakeHttpAdapter(
          (options) => _jsonBody(<Object>[
            'flutter 下载',
            <String>['flutter 下载器', 'flutter 教程'],
            <Object>[],
            <Object>[],
          ]),
        );
        final provider = DioYouTubeStreamProvider(dio: _dioWith(adapter));

        final suggestions = await provider.suggestions('flutter 下载');

        expect(suggestions, <String>['flutter 下载器', 'flutter 教程']);
        expect(adapter.requests.single.method, 'GET');
        expect(
          adapter.requests.single.uri.toString(),
          YoutubeDlApiEndpoints.suggestions('flutter 下载').toString(),
        );
      },
    );

    test('Dio failures are wrapped in YoutubeDlStreamException', () async {
      final adapter = _FakeHttpAdapter((options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'offline',
        );
      });
      final provider = DioYouTubeStreamProvider(dio: _dioWith(adapter));

      expect(
        () => provider.loadPlayer('abc'),
        throwsA(
          isA<YoutubeDlStreamException>().having(
            (error) => error.message,
            'message',
            contains('offline'),
          ),
        ),
      );
    });
  });

  group('download plan arithmetic', () {
    test('single stream plan keeps size, container and stream type', () {
      final plan = YoutubeDlDownloadPlan.single(_audioOnly());
      expect(plan.requiresMuxer, isFalse);
      expect(plan.totalBytes, 500);
      expect(plan.containerExtension, 'm4a');
      expect(plan.streamType, YoutubeDlStreamType.audio);
      expect(plan.qualityLabel, '128 kbps');
      expect(plan.url.toString(), 'https://cdn.example.com/a140');
    });

    test('merged plan sums both track sizes and requires a muxer', () {
      final plan = YoutubeDlDownloadPlan.merged(
        video: _videoOnly(),
        audio: _audioOnly(),
      );
      expect(plan.requiresMuxer, isTrue);
      expect(plan.totalBytes, 2500);
      expect(plan.containerExtension, 'mp4');
      expect(plan.streamType, YoutubeDlStreamType.video);
      expect(plan.qualityLabel, '1080p + 128 kbps');
      expect(plan.url.toString(), 'https://cdn.example.com/v137');
      expect(plan.audioUrl.toString(), 'https://cdn.example.com/a140');
    });

    test('merged plan normalises a leading-dot container', () {
      final plan = YoutubeDlDownloadPlan.merged(
        video: _videoOnly(),
        audio: _audioOnly(),
        mergedExtension: '.mkv',
      );
      expect(plan.containerExtension, 'mkv');
    });
  });

  group('progress, speed and ETA', () {
    test('percent floors the source ratio', () {
      expect(
        const YoutubeDlProgress(
          downloadedBytes: 512,
          totalBytes: 1024,
          elapsed: Duration(seconds: 2),
        ).percent,
        50,
      );
      expect(
        const YoutubeDlProgress(
          downloadedBytes: 1,
          totalBytes: 3,
          elapsed: Duration(seconds: 1),
        ).percent,
        33,
      );
      expect(
        const YoutubeDlProgress(
          downloadedBytes: 999,
          totalBytes: 1000,
          elapsed: Duration(seconds: 1),
        ).percent,
        99,
      );
    });

    test('percent clamps over-reporting servers at 100', () {
      expect(
        const YoutubeDlProgress(
          downloadedBytes: 2000,
          totalBytes: 1000,
          elapsed: Duration(seconds: 1),
        ).percent,
        100,
      );
    });

    test('speed is bytes * 1000 / elapsed milliseconds', () {
      final progress = const YoutubeDlProgress(
        downloadedBytes: 512,
        totalBytes: 1024,
        elapsed: Duration(seconds: 2),
      );
      expect(progress.bytesPerSecond, 256);
      expect(progress.speedLabel, '256.00 B/s');
    });

    test('ETA is remaining bytes divided by average speed, rounded up', () {
      final progress = const YoutubeDlProgress(
        downloadedBytes: 512,
        totalBytes: 1024,
        elapsed: Duration(seconds: 2),
      );
      expect(progress.eta, const Duration(seconds: 2));
      expect(progress.etaLabel, '00:02');

      final slower = const YoutubeDlProgress(
        downloadedBytes: 1,
        totalBytes: 1000,
        elapsed: Duration(seconds: 1),
      );
      expect(slower.bytesPerSecond, 1);
      expect(slower.eta, const Duration(seconds: 999));
    });

    test('unknown total size means indeterminate with no ETA', () {
      final progress = const YoutubeDlProgress(
        downloadedBytes: 100,
        totalBytes: 0,
        elapsed: Duration(seconds: 2),
      );
      expect(progress.percent, 0);
      expect(progress.isIndeterminate, isTrue);
      expect(progress.eta, Duration.zero);
    });

    test('zero elapsed never divides by zero', () {
      final progress = const YoutubeDlProgress(
        downloadedBytes: 100,
        totalBytes: 200,
        elapsed: Duration.zero,
      );
      expect(progress.bytesPerSecond, 0);
      expect(progress.speedLabel, '0.00 B/s');
      expect(progress.eta, Duration.zero);
    });

    test('completed progress is 100% regardless of counters', () {
      final progress = const YoutubeDlProgress(
        downloadedBytes: 0,
        totalBytes: 0,
        elapsed: Duration(seconds: 1),
        completed: true,
      );
      expect(progress.percent, 100);
      expect(progress.eta, Duration.zero);
    });
  });

  group('bytes and duration formatting', () {
    test('bytes use binary units with two decimals', () {
      expect(YoutubeDlBytes.format(0), '0.00 B');
      expect(YoutubeDlBytes.format(1023), '1023.00 B');
      expect(YoutubeDlBytes.format(1024), '1.00 KB');
      expect(YoutubeDlBytes.format(1536), '1.50 KB');
      expect(YoutubeDlBytes.format(1048576), '1.00 MB');
      expect(YoutubeDlBytes.format(1073741824), '1.00 GB');
    });

    test('durations render mm:ss below one hour and h:mm:ss above', () {
      expect(YoutubeDlDuration.format(const Duration(seconds: 5)), '00:05');
      expect(YoutubeDlDuration.format(const Duration(seconds: 65)), '01:05');
      expect(YoutubeDlDuration.format(const Duration(seconds: 754)), '12:34');
      expect(
        YoutubeDlDuration.format(const Duration(seconds: 3723)),
        '1:02:03',
      );
      expect(YoutubeDlDuration.format(const Duration(seconds: -3)), '00:00');
    });
  });

  group('filename sanitisation', () {
    test('source invalid characters become underscores', () {
      expect(
        YoutubeDlFileName.sanitize(r'a/b\c:d*e?f"g<h>i|j'),
        'a_b_c_d_e_f_g_h_i_j',
      );
    });

    test('non-ASCII characters such as fullwidth colons survive', () {
      expect(YoutubeDlFileName.sanitize('视频：测试/第 1 集'), '视频：测试_第 1 集');
    });

    test('surrounding whitespace is trimmed and empty names fall back', () {
      expect(YoutubeDlFileName.sanitize('  hello  '), 'hello');
      expect(YoutubeDlFileName.sanitize('   '), 'video');
      expect(YoutubeDlFileName.withExtension('', 'mp4'), 'video.mp4');
    });

    test('extensions are normalised and appended once', () {
      expect(YoutubeDlFileName.withExtension('a/b', 'mp4'), 'a_b.mp4');
      expect(YoutubeDlFileName.withExtension('a/b', '.webm'), 'a_b.webm');
    });

    test('collision candidates strip an existing numeric suffix first', () {
      expect(
        YoutubeDlFileName.collisionCandidate('/tmp/a.mp4', 1),
        '/tmp/a (1).mp4',
      );
      expect(
        YoutubeDlFileName.collisionCandidate('/tmp/a (7).mp4', 1),
        '/tmp/a (1).mp4',
      );
      expect(
        YoutubeDlFileName.collisionCandidate('/tmp/a.b.mp4', 2),
        '/tmp/a.b (2).mp4',
      );
      expect(YoutubeDlFileName.collisionCandidate('/tmp/a', 3), '/tmp/a (3)');
    });

    test('join and temp names follow the source conventions', () {
      expect(YoutubeDlFileName.join('/tmp', 'a.mp4'), '/tmp/a.mp4');
      expect(YoutubeDlFileName.join('/tmp/', 'a.mp4'), '/tmp/a.mp4');
      expect(YoutubeDlFileName.tempName(7), 'Unconfirmed 7.ytdownload');
      expect(
        YoutubeDlFileName.tempName(7, container: 'mp4'),
        'Unconfirmed 7.ytdownload.mp4',
      );
    });
  });

  group('download queue', () {
    test('a single stream runs to done and reports its file', () async {
      final sink = _RecordingSink();
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final queued = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      await queue.whenIdle();

      final task = queue.taskById(queued.id)!;
      expect(task.status, YoutubeDlDownloadStatus.done);
      expect(task.downloadedBytes, 1000);
      expect(task.filePath, '/downloads/A_B_ Test.mp4');
      expect(task.container, 'mp4');
      expect(sink.writes.single.path, '/downloads/A_B_ Test.mp4');
      expect(sink.writes.single.url.toString(), 'https://cdn.example.com/v18');
      expect(sink.writes.single.totalBytes, 1000);
      expect(queue.isIdle, isTrue);
    });

    test('existing files get a (1) suffix', () async {
      final sink = _RecordingSink(files: <String>{'/downloads/A_B_ Test.mp4'});
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final queued = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      await queue.whenIdle();

      expect(
        queue.taskById(queued.id)!.filePath,
        '/downloads/A_B_ Test (1).mp4',
      );
    });

    test(
      'cancel stops an in-flight write and marks the task cancelled',
      () async {
        final started = Completer<void>();
        final sink = _RecordingSink(
          handler: (call) async {
            if (!started.isCompleted) started.complete();
            await call.cancellation.whenCancelled;
            throw const YoutubeDlDownloadCancelledException();
          },
        );
        final queue = _queueFor(sink);
        addTearDown(queue.dispose);

        final queued = queue.enqueue(
          video: _video(),
          plan: YoutubeDlDownloadPlan.single(_muxed()),
        );
        await started.future;
        queue.cancel(queued.id);
        await queue.whenIdle();

        final task = queue.taskById(queued.id)!;
        expect(task.status, YoutubeDlDownloadStatus.cancelled);
        expect(task.finishedAt, isNotNull);
        expect(sink.writes.length, 1);
      },
    );

    test('pause marks paused and resume restarts from byte zero', () async {
      var calls = 0;
      final started = Completer<void>();
      final sink = _RecordingSink(
        handler: (call) async {
          calls++;
          if (calls == 1) {
            if (!started.isCompleted) started.complete();
            await call.cancellation.whenCancelled;
            throw const YoutubeDlDownloadCancelledException();
          }
          call.onProgress(call.totalBytes);
        },
      );
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final queued = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      await started.future;
      queue.pause(queued.id);
      expect(queue.taskById(queued.id)!.status, YoutubeDlDownloadStatus.paused);
      expect(queue.taskById(queued.id)!.status.isTerminal, isFalse);

      await Future<void>.delayed(Duration.zero);
      queue.resume(queued.id);
      await queue.whenIdle();

      final task = queue.taskById(queued.id)!;
      expect(task.status, YoutubeDlDownloadStatus.done);
      expect(sink.writes.length, 2);
      expect(sink.deletions, contains(sink.writes.first.path));
    });

    test('sink failures surface as failed with the exception text', () async {
      final sink = _RecordingSink(
        handler: (call) async => throw Exception('disk full'),
      );
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final queued = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      await queue.whenIdle();

      final task = queue.taskById(queued.id)!;
      expect(task.status, YoutubeDlDownloadStatus.failed);
      expect(task.error, contains('disk full'));
      expect(task.finishedAt, isNotNull);
    });

    test('split plans become needsMuxer without writing anything', () async {
      final sink = _RecordingSink();
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final task = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.merged(
          video: _videoOnly(),
          audio: _audioOnly(),
        ),
      );
      await queue.whenIdle();

      expect(task.status, YoutubeDlDownloadStatus.needsMuxer);
      expect(task.error, contains('FFmpeg'));
      expect(task.totalBytes, 2500);
      expect(task.container, 'mp4');
      expect(task.audioUrl, 'https://cdn.example.com/a140');
      expect(sink.writes, isEmpty);
      expect(queue.isIdle, isTrue);
    });

    test('maxConcurrent=1 serialises queued downloads', () async {
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();
      final sink = _RecordingSink(
        handler: (call) async {
          if (call.path.contains('One')) {
            if (!firstStarted.isCompleted) firstStarted.complete();
            await releaseFirst.future;
          }
          call.onProgress(call.totalBytes);
        },
      );
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      queue.enqueue(
        video: _video(title: 'One'),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      final second = queue.enqueue(
        video: _video(title: 'Two'),
        plan: YoutubeDlDownloadPlan.single(_muxed(size: 500)),
      );
      await firstStarted.future;
      expect(sink.writes.length, 1);
      expect(
        queue.taskById(second.id)!.status,
        YoutubeDlDownloadStatus.pending,
      );

      releaseFirst.complete();
      await queue.whenIdle();
      expect(sink.writes.length, 2);
      expect(sink.writes.last.path, '/downloads/Two.mp4');
    });

    test('remove deletes the written file and drops the task', () async {
      final sink = _RecordingSink();
      final queue = _queueFor(sink);
      addTearDown(queue.dispose);

      final queued = queue.enqueue(
        video: _video(),
        plan: YoutubeDlDownloadPlan.single(_muxed()),
      );
      await queue.whenIdle();
      final path = queue.taskById(queued.id)!.filePath;

      await queue.remove(queued.id);

      expect(queue.taskById(queued.id), isNull);
      expect(sink.deletions, contains(path));
      expect(sink.files, isEmpty);
    });
  });

  group('widgets', () {
    testWidgets('download tile renders percent, speed and ETA', (tester) async {
      final startedAt = DateTime(2026, 1, 1, 0, 0, 0);
      final task = YoutubeDlDownloadTask(
        id: 't1',
        videoId: 'v1',
        title: '演示视频',
        status: YoutubeDlDownloadStatus.running,
        streamType: YoutubeDlStreamType.video,
        url: 'https://example.com/v',
        container: 'mp4',
        totalBytes: 1024,
        downloadedBytes: 512,
        createdAt: startedAt,
        startedAt: startedAt,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoutubeDlDownloadTile(
              task: task,
              now: startedAt.add(const Duration(seconds: 2)),
              onPause: () {},
              onResume: () {},
              onCancel: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('50%'), findsOneWidget);
      expect(find.textContaining('256.00 B/s'), findsOneWidget);
      expect(find.textContaining('剩余 00:02'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('needs-muxer tile hides the progress bar and says why', (
      tester,
    ) async {
      final task = YoutubeDlDownloadTask(
        id: 't2',
        videoId: 'v1',
        title: '需要合成的视频',
        status: YoutubeDlDownloadStatus.needsMuxer,
        streamType: YoutubeDlStreamType.video,
        url: 'https://example.com/v',
        audioUrl: 'https://example.com/a',
        container: 'mp4',
        totalBytes: 2500,
        createdAt: DateTime(2026, 1, 1),
        error: YoutubeDlDownloadQueue.muxerMessage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoutubeDlDownloadTile(
              task: task,
              now: DateTime(2026, 1, 1),
              onPause: () {},
              onResume: () {},
              onCancel: () {},
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('FFmpeg'), findsOneWidget);
      expect(find.byTooltip('删除'), findsOneWidget);
    });

    testWidgets('page exposes search and downloads tabs', (tester) async {
      final queue = _queueFor(_RecordingSink());
      addTearDown(queue.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: YoutubeDlPage(provider: _UnusedProvider(), queue: queue),
        ),
      );

      expect(find.text('YouTube 下载'), findsOneWidget);
      expect(find.text('搜索'), findsNWidgets(2));
      expect(find.text('下载'), findsOneWidget);
      expect(find.text('搜索 YouTube 视频'), findsOneWidget);
    });
  });
}
