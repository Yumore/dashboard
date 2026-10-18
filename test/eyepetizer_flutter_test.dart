import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_account_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_attention_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_author.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_provider.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_bloc.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_community_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_config.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_countdown_button.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_countdown_button_state.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_database.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_date_util.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_exception.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_footer_view_state.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_http.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_load_status.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login_page_state.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_member.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_owner.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_home_parser.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_model.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_key.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_util.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_register_page_state.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_sqlite_helper.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_string_util.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_strings.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_upload_picture.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_user_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A network-free [HttpClientAdapter] that records the request it was handed and
/// replays one canned JSON body.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.body = '{}', this.statusCode = 200, this.throwing = false});

  String body;
  int statusCode;
  bool throwing;
  int calls = 0;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    lastRequest = options;
    if (throwing) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: EyepetizerFlutterEndpoint.baseUrl));
  dio.httpClientAdapter = adapter;
  return dio;
}

/// An in-memory [EyepetizerFlutterDatabase], so the cache rules are assertable
/// without the sqflite plugin.
class _FakeDatabase implements EyepetizerFlutterDatabase {
  _FakeDatabase({this.tableExists = true});

  bool tableExists;
  final List<String> executedSql = <String>[];
  final List<String> rawQueries = <String>[];
  final List<Map<String, Object?>> inserts = <Map<String, Object?>>[];
  final List<String> deletedTagArguments = <String>[];
  List<Map<String, Object?>> queryRows = <Map<String, Object?>>[];

  @override
  Future<void> execute(String sql) async {
    executedSql.add(sql);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    rawQueries.add(sql);
    if (!tableExists) return <Map<String, Object?>>[];
    return <Map<String, Object?>>[
      <String, Object?>{'name': 'base_list'},
    ];
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    inserts.add(values);
    return 1;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    deletedTagArguments.add(whereArgs == null ? '' : '${whereArgs.first}');
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  }) async => queryRows;

  @override
  Future<void> close() async {}
}

/// A [EyepetizerFlutterCommunityRepository] that never touches the network.
class _FakeCommunityRepository extends EyepetizerFlutterCommunityRepository {
  _FakeCommunityRepository(this.results);

  final List<EyepetizerFlutterBaseListData> results;
  final List<String?> requestedNextPageUrls = <String?>[];
  Object? failure;
  int _index = 0;

  @override
  Future<EyepetizerFlutterBaseListData> getCommunityRecommendData({
    String? nextPageUrl,
  }) async {
    requestedNextPageUrls.add(nextPageUrl);
    final error = failure;
    if (error != null) throw error;
    final result = _index < results.length ? results[_index] : results.last;
    _index++;
    return result;
  }

  @override
  void dispose() {}
}

EyepetizerFlutterItem _columnCard({String description = '一张图'}) =>
    EyepetizerFlutterItem(
      type: EyepetizerFlutterCommunityBloc.columnCardType,
      data: EyepetizerFlutterItemData(description: description),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('endpoint and config constants', () {
    test('base URLs stay on the two hosts the source declared', () {
      expect(
        EyepetizerFlutterEndpoint.baseUrl,
        'https://baobab.kaiyanapp.com',
      );
      expect(
        EyepetizerFlutterEndpoint.accountBaseUrl,
        'https://account.kaiyanapp.com',
      );
    });

    test('account, community and person paths are verbatim', () {
      expect(
        EyepetizerFlutterEndpoint.getVerificationCode,
        '/v1/api/sms/initialization',
      );
      expect(EyepetizerFlutterEndpoint.register, '/v2/api/register');
      expect(EyepetizerFlutterEndpoint.login, '/v1/api/login');
      expect(
        EyepetizerFlutterEndpoint.communityRecommend,
        '/api/v7/community/tab/rec',
      );
      expect(EyepetizerFlutterEndpoint.personHomepage, '/api/v5/userInfo/tab');
      expect(EyepetizerFlutterEndpoint.uploadPicture, '/api/tools/image');
      expect(EyepetizerFlutterEndpoint.editUserData, '/api/v5/userInfo/edit');
    });

    test('video detail is a prefix the repository concatenates an id onto', () {
      expect(EyepetizerFlutterEndpoint.videoDetail, '/api/v2/video/');
      expect(EyepetizerFlutterEndpoint.relateVideo, '/api/v4/video/related');
    });

    test('the device coordinates are the source hard-coded values', () {
      expect(
        EyepetizerFlutterConfig.udid,
        '6a6fa0cffa894788983cce8dc7d33cd7c508f3bb',
      );
      expect(EyepetizerFlutterConfig.udid.length, 40);
      expect(EyepetizerFlutterConfig.vc, '6030071');
      expect(EyepetizerFlutterConfig.vn, '6.3.7');
      expect(EyepetizerFlutterConfig.size, '1080X2210');
      expect(EyepetizerFlutterConfig.deviceModel, 'MIX 3');
      expect(EyepetizerFlutterConfig.firstChannel, 'xiaomi');
      expect(EyepetizerFlutterConfig.lastChannel, 'xiaomi');
      expect(EyepetizerFlutterConfig.systemVersionCode, '29');
    });
  });

  group('EyepetizerFlutterJson coercers', () {
    test('asInt converts numbers and numeric strings, else zero', () {
      expect(EyepetizerFlutterJson.asInt(12), 12);
      expect(EyepetizerFlutterJson.asInt(3.9), 3);
      expect(EyepetizerFlutterJson.asInt('42'), 42);
      expect(EyepetizerFlutterJson.asInt('nope'), 0);
      expect(EyepetizerFlutterJson.asInt(null), 0);
    });

    test('asNullableInt keeps absence distinguishable from zero', () {
      expect(EyepetizerFlutterJson.asNullableInt(null), isNull);
      expect(EyepetizerFlutterJson.asNullableInt('7'), 7);
      expect(EyepetizerFlutterJson.asNullableInt('seven'), isNull);
      expect(EyepetizerFlutterJson.asNullableInt(0), 0);
    });

    test('asMapList skips entries that are not maps', () {
      final list = EyepetizerFlutterJson.asMapList(<Object?>[
        <String, Object?>{'a': 1},
        'nope',
         7,
        <String, Object?>{'b': 2},
      ]);
      expect(list, hasLength(2));
      expect(list.first['a'], 1);
      expect(EyepetizerFlutterJson.asMapList(null), isEmpty);
    });

    test('asMap keys are stringified and a non-map degrades to empty', () {
      expect(EyepetizerFlutterJson.asMap(<Object?, Object?>{1: 'one'})['1'], 'one');
      expect(EyepetizerFlutterJson.asMap('nope'), isEmpty);
      expect(EyepetizerFlutterJson.asMapOrNull(<String, Object?>{'a': 1}), isNotNull);
      expect(EyepetizerFlutterJson.asMapOrNull(<Object?>[]), isNull);
    });

    test('asString and asNullableString differ on empty and whitespace', () {
      expect(EyepetizerFlutterJson.asString(null), '');
      expect(EyepetizerFlutterJson.asString(5), '5');
      expect(EyepetizerFlutterJson.asNullableString('  '), isNull);
      expect(EyepetizerFlutterJson.asNullableString('  x '), 'x');
      expect(EyepetizerFlutterJson.asNullableString(null), isNull);
    });

    test('asStringList stringifies every entry', () {
      expect(
        EyepetizerFlutterJson.asStringList(<Object?>['a', 2]),
        <String>['a', '2'],
      );
      expect(EyepetizerFlutterJson.asStringList('nope'), isEmpty);
    });

    test('asBool only accepts the literal true', () {
      expect(EyepetizerFlutterJson.asBool(true), isTrue);
      expect(EyepetizerFlutterJson.asBool('true'), isTrue);
      expect(EyepetizerFlutterJson.asBool('yes'), isFalse);
      expect(EyepetizerFlutterJson.asBool(null), isFalse);
    });

    test('StringUtil.isEmpty follows the source null/String/Iterable/Map rule', () {
      expect(EyepetizerFlutterStringUtil.isEmpty(null), isTrue);
      expect(EyepetizerFlutterStringUtil.isEmpty(''), isTrue);
      expect(EyepetizerFlutterStringUtil.isEmpty(<String>[]), isTrue);
      expect(EyepetizerFlutterStringUtil.isEmpty(<String, Object?>{}), isTrue);
      expect(EyepetizerFlutterStringUtil.isEmpty('x'), isFalse);
      expect(EyepetizerFlutterStringUtil.isEmpty(0), isFalse);
    });
  });

  group('account models', () {
    test('BaseData reads error and msg', () {
      final data = EyepetizerFlutterBaseData.fromJson(
        <String, dynamic>{'error': 0, 'msg': 'ok'},
      );
      expect(data.error, 0);
      expect(data.msg, 'ok');
    });

    test('Login carries a member when the payload has one', () {
      final login = EyepetizerFlutterLogin.fromJson(<String, dynamic>{
        'error': 0,
        'msg': '登录成功',
        'member': <String, dynamic>{'uid': 9, 'nick': '阿开'},
      });
      expect(login.error, 0);
      expect(login.msg, '登录成功');
      expect(login.member!.uid, 9);
      expect(login.member!.nick, '阿开');
    });

    test('Login without a member stays null instead of throwing', () {
      final login = EyepetizerFlutterLogin.fromJson(<String, dynamic>{
        'error': 1,
        'msg': '密码错误',
      });
      expect(login.member, isNull);
      expect(login.toJson()['member'], isNull);
    });

    test('Member defaults devices and roles to empty lists', () {
      final member = EyepetizerFlutterMember.fromJson(<String, dynamic>{
        'uid': 5,
      });
      expect(member.devices, isEmpty);
      expect(member.roles, isEmpty);
    });

    test('Member parses devices and roles', () {
      final member = EyepetizerFlutterMember.fromJson(<String, dynamic>{
        'uid': 5,
        'telephone': '13800000000',
        'roles': <Object?>['user', 'vip'],
        'devices': <Object?>[
          <String, dynamic>{'id': 1, 'udid': 'abc'},
        ],
      });
      expect(member.telephone, '13800000000');
      expect(member.roles, <String>['user', 'vip']);
      expect(member.devices.single.udid, 'abc');
    });

    test('the stored login JSON round-trips through prefs', () async {
      final member = EyepetizerFlutterMember.fromJson(<String, dynamic>{
        'uid': 7,
        'nick': '阿开',
      });
      final login = EyepetizerFlutterLogin(error: 0, msg: 'ok', member: member);
      final restored = EyepetizerFlutterLogin.fromJson(login.toJson());
      expect(restored.member!.uid, 7);
      expect(restored.member!.nick, '阿开');
    });
  });

  group('feed models', () {
    test('BaseListData defaults code to 0 and itemList to empty', () {
      final data = EyepetizerFlutterBaseListData.fromJson(
        <String, dynamic>{},
      );
      expect(data.code, 0);
      expect(data.itemList, isEmpty);
      expect(data.nextPageUrl, isNull);
      expect(data.header, isNull);
    });

    test('BaseListData toJson emits the four source keys', () {
      final json = EyepetizerFlutterBaseListData(
        code: 200,
        itemList: <EyepetizerFlutterItem>[
          EyepetizerFlutterItem(
            type: 'followCard',
            data: EyepetizerFlutterItemData(title: '标题'),
          ),
        ],
        nextPageUrl: 'https://baobab.kaiyanapp.com/api/v5/userInfo/tab?start=10',
      ).toJson();
      expect(json.keys.toSet(), <String>{
        'code',
        'itemList',
        'nextPageUrl',
        'header',
      });
      expect(json['code'], 200);
    });

    test('BaseListData parses items and nextPageUrl', () {
      final data = EyepetizerFlutterBaseListData.fromJson(<String, dynamic>{
        'code': 200,
        'itemList': <Object?>[
          <String, dynamic>{
            'type': 'communityColumnsCard',
            'data': <String, dynamic>{'description': '一张图'},
          },
        ],
        'nextPageUrl': 'https://baobab.kaiyanapp.com/api/v7/community/tab/rec?start=10',
      });
      expect(data.code, 200);
      expect(data.itemList.single.type, 'communityColumnsCard');
      expect(data.itemList.single.data!.description, '一张图');
      expect(data.nextPageUrl, contains('start=10'));
    });

    test('ItemData keeps its duration on fromJson but drops it from toJson', () {
      final parsed = EyepetizerFlutterItemData.fromJson(<String, dynamic>{
        'title': 't',
        'duration': 42,
      });
      expect(parsed.duration, 42);
      final json = parsed.toJson();
      expect(json.containsKey('duration'), isFalse);
      expect(EyepetizerFlutterItemData.fromJson(json).duration, 0);
    });

    test('ItemData defaults a missing duration to zero', () {
      expect(
        EyepetizerFlutterItemData.fromJson(<String, dynamic>{}).duration,
        0,
      );
    });

    test('ItemBannerData falls back to bgPicture when image is absent', () {
      final parsed = EyepetizerFlutterItemBannerData.fromJson(<String, dynamic>{
        'bgPicture': 'https://img/bg.jpg',
      });
      expect(parsed.image, 'https://img/bg.jpg');
    });

    test('ItemBannerData prefers image over bgPicture', () {
      final parsed = EyepetizerFlutterItemBannerData.fromJson(<String, dynamic>{
        'image': 'https://img/image.jpg',
        'bgPicture': 'https://img/bg.jpg',
      });
      expect(parsed.image, 'https://img/image.jpg');
    });

    test('Owner defaults a missing city to an empty string', () {
      expect(EyepetizerFlutterOwner.fromJson(<String, dynamic>{'uid': 1}).city, '');
      expect(
        EyepetizerFlutterOwner.fromJson(<String, dynamic>{'city': '北京'}).city,
        '北京',
      );
    });

    test('Author defaults a missing icon to an empty string', () {
      expect(EyepetizerFlutterAuthor.fromJson(<String, dynamic>{'name': 'n'}).icon, '');
    });

    test('Detail defaults tags and urls to empty lists when absent', () {
      final detail = EyepetizerFlutterDetail.fromJson(<String, dynamic>{'id': 3});
      expect(detail.id, 3);
      expect(detail.tags, isEmpty);
      expect(detail.urls, isEmpty);
    });

    test('Detail parses tags and the picture url list', () {
      final detail = EyepetizerFlutterDetail.fromJson(<String, dynamic>{
        'id': 3,
        'tags': <Object?>[
          <String, dynamic>{'id': 1, 'name': '摄影'},
        ],
        'urls': <Object?>['https://img/a.jpg', 'https://img/b.jpg'],
      });
      expect(detail.tags.single.name, '摄影');
      expect(detail.urls, <String>['https://img/a.jpg', 'https://img/b.jpg']);
    });

    test('ContentData defaults tags to an empty list', () {
      final content = EyepetizerFlutterContentData.fromJson(<String, dynamic>{
        'id': 8,
        'resourceType': 'ugc_picture',
      });
      expect(content.id, 8);
      expect(content.resourceType, 'ugc_picture');
      expect(content.tags, isEmpty);
    });

    test('UploadPicture maps the nested upload item', () {
      final picture = EyepetizerFlutterUploadPicture.fromJson(<String, dynamic>{
        'errorCode': 0,
        'errorMessage': '',
        'item': <String, dynamic>{
          'width': 640,
          'height': 480,
          'format': 'png',
          'url': 'https://cdn/x.png',
        },
      });
      expect(picture.errorCode, 0);
      expect(picture.item!.width, 640);
      expect(picture.item!.height, 480);
      expect(picture.item!.format, 'png');
      expect(picture.item!.url, 'https://cdn/x.png');
    });
  });

  group('person models', () {
    test('PersonMainModel prefers userInfo and falls back to pgcInfo', () {
      final withUserInfo = EyepetizerFlutterPersonMainModel.fromJson(
        <String, dynamic>{
          'userInfo': <String, dynamic>{'id': 1, 'name': '普通用户'},
          'pgcInfo': <String, dynamic>{'id': 2, 'name': 'PGC'},
        },
      );
      expect(withUserInfo.userInfo!.id, 1);
      expect(withUserInfo.userInfo!.name, '普通用户');

      final withPgcInfo = EyepetizerFlutterPersonMainModel.fromJson(
        <String, dynamic>{
          'pgcInfo': <String, dynamic>{'id': 2, 'name': 'PGC'},
        },
      );
      expect(withPgcInfo.userInfo!.id, 2);
      expect(withPgcInfo.tabInfo, isNull);
    });

    test('UserInfo defaults icon, description and cover to empty strings', () {
      final user = EyepetizerFlutterUserInfo.fromJson(<String, dynamic>{
        'id': 4,
        'name': '名字',
      });
      expect(user.icon, '');
      expect(user.description, '');
      expect(user.cover, '');
      expect(user.name, '名字');
      expect(user.birthday, isNull);
    });

    test('UserInfo toJson emits all thirty fields', () {
      final user = EyepetizerFlutterUserInfo.fromJson(<String, dynamic>{
        'id': 4,
        'medalsNum': 3,
      });
      final json = user.toJson();
      expect(json.length, 30);
      expect(json['medalsNum'], 3);
      expect(json['icon'], '');
    });

    test('isMyselfArgument reproduces the source length check', () {
      expect(EyepetizerFlutterPersonMainPage.isMyselfArgument(1234), isFalse);
      expect(EyepetizerFlutterPersonMainPage.isMyselfArgument(12345), isTrue);
      expect(
        EyepetizerFlutterPersonMainPage.isMyselfArgument(
          EyepetizerFlutterUserInfo.fromJson(<String, dynamic>{'id': 1}),
        ),
        isTrue,
      );
      expect(EyepetizerFlutterPersonMainPage.isMyselfArgument(null), isFalse);
    });
  });

  group('person home parser', () {
    Map<String, dynamic> collectionPage() => <String, dynamic>{
      'code': 200,
      'itemList': <Object?>[
        <String, dynamic>{
          'type': 'videoCollectionOfHorizontalScrollCard',
          'header': <String, dynamic>{
            'id': 1,
            'title': '我的收藏',
            'icon': 'outer-icon',
            'description': '收藏合集',
          },
          'data': <String, dynamic>{
            'itemList': <Object?>[
              <String, dynamic>{
                'type': 'videoSmallCard',
                'data': <String, dynamic>{
                  'dataType': 'VideoBeanForClient',
                  'id': 7,
                  'header': <String, dynamic>{
                    'id': 2,
                    'title': '视频标题',
                    'icon': 'inner-icon',
                    'description': '视频描述',
                  },
                  'content': <String, dynamic>{
                    'data': <String, dynamic>{
                      'cover': <String, dynamic>{
                        'feed': 'https://img/cover.jpg',
                      },
                    },
                  },
                  'actionUrl': 'eyepetizer://detail/7',
                },
              },
              <String, dynamic>{
                'type': 'videoSmallCard',
                'data': <String, dynamic>{'id': 8},
              },
            ],
          },
        },
        <String, dynamic>{
          'type': 'followCard',
          'data': <String, dynamic>{'title': '别的卡片'},
        },
      ],
      'nextPageUrl': 'https://baobab.kaiyanapp.com/api/v5/userInfo/tab?start=10',
    };

    test('only the collection card is expanded into banners', () {
      final parsed = EyepetizerFlutterPersonHomeParser.parse(collectionPage());
      expect(parsed.itemList, hasLength(2));
      final banners = parsed.itemList.first.data!.itemList;
      expect(banners, hasLength(2));
      expect(banners.first.type, 'videoSmallCard');
      expect(banners.first.data!.title, '视频标题');
      expect(banners.first.data!.image, 'https://img/cover.jpg');
      expect(banners.first.data!.actionUrl, 'eyepetizer://detail/7');
      expect(banners.first.data!.icon, 'inner-icon');
      expect(banners.first.data!.description, '视频描述');
      expect(banners.first.data!.subTitle, '');
      expect(banners.first.data!.bgPicture, '');
      expect(banners.first.data!.label, isNull);
    });

    test('the banner header is the outer card header, on every banner', () {
      final parsed = EyepetizerFlutterPersonHomeParser.parse(collectionPage());
      final banners = parsed.itemList.first.data!.itemList;
      for (final banner in banners) {
        expect(banner.header!.title, '我的收藏');
        expect(banner.header!.icon, 'outer-icon');
      }
      expect(banners.last.data!.header, isNull);
    });

    test('banners are written onto itemList[0] even when the card is later', () {
      final page = collectionPage();
      final items = page['itemList']! as List<Object?>;
      final card = items.first;
      items
        ..clear()
        ..add(<String, dynamic>{
          'type': 'followCard',
          'data': <String, dynamic>{'title': '第一张'},
        })
        ..add(card);
      final parsed = EyepetizerFlutterPersonHomeParser.parse(page);
      expect(parsed.itemList.first.type, 'followCard');
      expect(parsed.itemList.first.data!.itemList, hasLength(2));
      expect(parsed.itemList.first.data!.itemList.first.type, 'videoSmallCard');
      // The collection card keeps its own nested list; the accumulator went to
      // index 0 instead, exactly like the source's `itemList[0]` write.
      expect(parsed.itemList.last.type, 'videoCollectionOfHorizontalScrollCard');
      expect(parsed.itemList.last.data!.itemList, hasLength(2));
    });

    test('a page with no collection card leaves every itemList empty', () {
      final parsed = EyepetizerFlutterPersonHomeParser.parse(<String, dynamic>{
        'code': 200,
        'itemList': <Object?>[
          <String, dynamic>{
            'type': 'followCard',
            'data': <String, dynamic>{'title': 'x'},
          },
        ],
      });
      expect(parsed.itemList.single.data!.itemList, isEmpty);
    });

    test('a page with an empty itemList does not throw', () {
      final parsed = EyepetizerFlutterPersonHomeParser.parse(<String, dynamic>{
        'code': 200,
        'itemList': <Object?>[],
      });
      expect(parsed.itemList, isEmpty);
      expect(parsed.code, 200);
    });

    test('elements without data are skipped rather than crashing', () {
      final parsed = EyepetizerFlutterPersonHomeParser.parse(<String, dynamic>{
        'itemList': <Object?>[
          <String, dynamic>{
            'type': EyepetizerFlutterPersonHomeParser.collectionCardType,
            'header': <String, dynamic>{'title': 'h'},
            'data': <String, dynamic>{
              'itemList': <Object?>[
                <String, dynamic>{'type': 'videoSmallCard'},
              ],
            },
          },
          <String, dynamic>{
            'type': 'videoSmallCard',
            'data': <String, dynamic>{'id': 1},
          },
        ],
      });
      expect(parsed.itemList.first.data!.itemList, isEmpty);
    });
  });

  group('http transport', () {
    test('a JSON string body is decoded into a map', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'code': 200}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final result = await http.request(
        EyepetizerFlutterEndpoint.communityRecommend,
        method: 'GET',
      );
      expect(result['code'], 200);
      http.dispose();
    });

    test('a JSON array body is refused with the source message', () async {
      final adapter = _FakeAdapter(body: '[]');
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      await expectLater(
        http.request(EyepetizerFlutterEndpoint.communityRecommend, method: 'GET'),
        throwsA(
          isA<EyepetizerFlutterException>().having(
            (error) => error.message,
            'message',
            '开眼返回的数据格式无法解析',
          ),
        ),
      );
      http.dispose();
    });

    test('an HTTP error becomes 请求失败：HTTP <status>', () async {
      final adapter = _FakeAdapter(body: '{}', statusCode: 500);
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      await expectLater(
        http.request(EyepetizerFlutterEndpoint.communityRecommend, method: 'GET'),
        throwsA(
          isA<EyepetizerFlutterException>()
              .having((error) => error.message, 'message', '请求失败：HTTP 500')
              .having((error) => error.statusCode, 'statusCode', 500),
        ),
      );
      http.dispose();
    });

    test('a connection failure is reported in Chinese', () async {
      final adapter = _FakeAdapter(throwing: true);
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      await expectLater(
        http.request(EyepetizerFlutterEndpoint.communityRecommend, method: 'GET'),
        throwsA(
          isA<EyepetizerFlutterException>().having(
            (error) => error.message,
            'message',
            '网络连接失败，请检查网络',
          ),
        ),
      );
      http.dispose();
    });

    test('every request carries the eight common query parameters', () async {
      final adapter = _FakeAdapter(body: '{}');
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      await http.request(
        EyepetizerFlutterEndpoint.communityRecommend,
        method: 'GET',
      );
      final query = adapter.lastRequest!.queryParameters;
      expect(query['udid'], EyepetizerFlutterConfig.udid);
      expect(query['vc'], EyepetizerFlutterConfig.vc);
      expect(query['vn'], EyepetizerFlutterConfig.vn);
      expect(query['size'], EyepetizerFlutterConfig.size);
      expect(query['deviceModel'], EyepetizerFlutterConfig.deviceModel);
      expect(query['first_channel'], EyepetizerFlutterConfig.firstChannel);
      expect(query['last_channel'], EyepetizerFlutterConfig.lastChannel);
      expect(
        query['system_version_code'],
        EyepetizerFlutterConfig.systemVersionCode,
      );
      http.dispose();
    });
  });

  group('account repository', () {
    test('login POSTs the credentials as query parameters', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{
          'error': 0,
          'msg': 'ok',
          'member': <String, Object?>{'uid': 9, 'nick': '阿开'},
        }),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterAccountRepository(http: http);
      final login = await repository.login('13800000000', 'secret');
      final request = adapter.lastRequest!;
      expect(request.method, 'POST');
      expect(request.baseUrl, EyepetizerFlutterEndpoint.accountBaseUrl);
      expect(request.path, EyepetizerFlutterEndpoint.login);
      expect(request.data, isNull);
      expect(request.queryParameters['username'], '13800000000');
      expect(request.queryParameters['password'], 'secret');
      expect(login.member!.nick, '阿开');
      repository.dispose();
    });

    test('register POSTs username, code and password', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'error': 0, 'msg': 'ok'}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterAccountRepository(http: http);
      final data = await repository.register('13800000000', '1234', 'secret');
      final query = adapter.lastRequest!.queryParameters;
      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.baseUrl, EyepetizerFlutterEndpoint.accountBaseUrl);
      expect(adapter.lastRequest!.path, EyepetizerFlutterEndpoint.register);
      expect(query['username'], '13800000000');
      expect(query['code'], '1234');
      expect(query['password'], 'secret');
      expect(data.error, 0);
      repository.dispose();
    });

    test('the verification code request sends telephone and type=sms', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'error': 0, 'msg': 'ok'}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterAccountRepository(http: http);
      await repository.getVerificationCode('13800000000');
      final request = adapter.lastRequest!;
      expect(request.method, 'POST');
      expect(request.baseUrl, EyepetizerFlutterEndpoint.accountBaseUrl);
      expect(
        request.path,
        EyepetizerFlutterEndpoint.getVerificationCode,
      );
      expect(request.queryParameters['telephone'], '13800000000');
      expect(request.queryParameters['type'], 'sms');
      repository.dispose();
    });
  });

  group('person repository', () {
    test('the profile request names id and userType=NORMAL for self', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{
          'userInfo': <String, Object?>{'id': 12, 'name': '我'},
        }),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterPersonRepository(http: http);
      final model = await repository.getPersonMainPageData(12, true);
      final request = adapter.lastRequest!;
      expect(request.method, 'GET');
      expect(request.path, EyepetizerFlutterEndpoint.personHomepage);
      expect(request.queryParameters['id'], 12);
      expect(request.queryParameters['userType'], 'NORMAL');
      expect(model.userInfo!.name, '我');
      repository.dispose();
    });

    test('another person is requested as userType=PGC', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{
          'userInfo': <String, Object?>{'id': 12},
        }),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterPersonRepository(http: http);
      await repository.getPersonMainPageData(12, false);
      expect(adapter.lastRequest!.queryParameters['userType'], 'PGC');
      repository.dispose();
    });

    test('a person-home page uses the absolute targetUrl as the path', () async {
      const nextPageUrl =
          'https://baobab.kaiyanapp.com/api/v5/userInfo/tab?start=10&num=10';
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{
          'code': 200,
          'itemList': <Object?>[],
          'nextPageUrl': nextPageUrl,
        }),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterPersonRepository(http: http);
      final page = await repository.getPersonHomePageData(nextPageUrl);
      final request = adapter.lastRequest!;
      expect(request.path, nextPageUrl);
      expect(request.baseUrl, '');
      expect(page.nextPageUrl, nextPageUrl);
      repository.dispose();
    });

    test('uploadPicture sends one multipart field named file', () async {
      final directory = await Directory.systemTemp.createTemp(
        'eyepetizer_flutter_upload',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/avatar.png')
        ..writeAsBytesSync(<int>[1, 2, 3]);
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{
          'errorCode': 0,
          'errorMessage': '',
          'item': <String, Object?>{'url': 'https://cdn/avatar.png'},
        }),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterPersonRepository(http: http);
      final picture = await repository.uploadPicture(file.path);
      final request = adapter.lastRequest!;
      expect(request.method, 'POST');
      expect(request.path, EyepetizerFlutterEndpoint.uploadPicture);
      final form = request.data;
      expect(form, isA<FormData>());
      final part = (form! as FormData).files.single;
      expect(part.key, 'file');
      expect(part.value.filename, 'avatar.png');
      expect(picture.item!.url, 'https://cdn/avatar.png');
      repository.dispose();
    });

    test('savePersonData translates the gender and sends all nine fields', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'error': 0, 'msg': 'ok'}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterPersonRepository(http: http);
      await repository.savePersonData(
        cover: 'cover.jpg',
        avatar: 'avatar.jpg',
        name: '名字',
        gender: '男',
        birthday: '1990/01/01',
        city: '北京',
        university: '某大学',
        job: '工程师',
        description: '简介',
      );
      final query = adapter.lastRequest!.queryParameters;
      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, EyepetizerFlutterEndpoint.editUserData);
      expect(query['nick'], '名字');
      expect(query['gender'], 'male');
      expect(query['birthday'], '1990/01/01');
      expect(query['city'], '北京');
      expect(query['university'], '某大学');
      expect(query['job'], '工程师');
      expect(query['description'], '简介');
      expect(query['avatar'], 'avatar.jpg');
      expect(query['cover'], 'cover.jpg');
      repository.dispose();
    });

    test('any gender other than 男 is sent as female', () {
      expect(EyepetizerFlutterPersonRepository.normaliseGender('男'), 'male');
      expect(EyepetizerFlutterPersonRepository.normaliseGender('女'), 'female');
      expect(EyepetizerFlutterPersonRepository.normaliseGender(''), 'female');
    });
  });

  group('community and detail repositories', () {
    test('an empty nextPageUrl keeps the plain recommend endpoint', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'code': 200, 'itemList': <Object?>[]}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterCommunityRepository(http: http);
      await repository.getCommunityRecommendData(nextPageUrl: '');
      final request = adapter.lastRequest!;
      expect(request.method, 'GET');
      expect(request.path, EyepetizerFlutterEndpoint.communityRecommend);
      expect(request.baseUrl, EyepetizerFlutterEndpoint.baseUrl);
      repository.dispose();
    });

    test('a nextPageUrl replaces the path and blanks the base URL', () async {
      const nextPageUrl =
          'https://baobab.kaiyanapp.com/api/v7/community/tab/rec?start=10';
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'code': 200, 'itemList': <Object?>[]}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterCommunityRepository(http: http);
      await repository.getCommunityRecommendData(nextPageUrl: nextPageUrl);
      final request = adapter.lastRequest!;
      expect(request.path, nextPageUrl);
      expect(request.baseUrl, '');
      repository.dispose();
    });

    test('video detail appends the id to the path prefix', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'id': 42, 'title': '图集'}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterDetailRepository(http: http);
      final detail = await repository.getVideoDetail(
        42,
        resourceType: 'ugc_picture',
      );
      final request = adapter.lastRequest!;
      expect(request.method, 'GET');
      expect(request.path, '/api/v2/video/42');
      expect(request.queryParameters['resourceType'], 'ugc_picture');
      expect(detail.title, '图集');
      repository.dispose();
    });

    test('related videos are requested by id', () async {
      final adapter = _FakeAdapter(
        body: jsonEncode(<String, Object?>{'code': 200, 'itemList': <Object?>[]}),
      );
      final http = EyepetizerFlutterHttp(dio: _dioWith(adapter));
      final repository = EyepetizerFlutterDetailRepository(http: http);
      await repository.getRelateVideo(9);
      final request = adapter.lastRequest!;
      expect(request.path, EyepetizerFlutterEndpoint.relateVideo);
      expect(request.queryParameters['id'], 9);
      repository.dispose();
    });
  });

  group('community bloc paging', () {
    test('refresh asks with an empty nextPageUrl', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[_columnCard()],
          nextPageUrl: 'page-2',
        ),
      ]);
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      await bloc.refresh();
      expect(fake.requestedNextPageUrls.single, '');
      expect(bloc.items, hasLength(1));
      expect(bloc.nextPageUrl, 'page-2');
      expect(bloc.loadStatus, EyepetizerFlutterLoadStatus.completed);
      bloc.dispose();
    });

    test('loadMore reuses the nextPageUrl the previous page returned', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[_columnCard(description: '第一页')],
          nextPageUrl: 'page-2',
        ),
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[_columnCard(description: '第二页')],
          nextPageUrl: 'page-3',
        ),
      ]);
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      await bloc.refresh();
      await bloc.loadMore();
      expect(fake.requestedNextPageUrls, <String?>['', 'page-2']);
      expect(bloc.items, hasLength(2));
      expect(bloc.nextPageUrl, 'page-3');
      bloc.dispose();
    });

    test('only communityColumnsCard items survive the filter', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[
            _columnCard(description: '留下'),
            EyepetizerFlutterItem(
              type: 'followCard',
              data: EyepetizerFlutterItemData(description: '丢掉'),
            ),
            EyepetizerFlutterItem(
              type: 'banner',
              data: EyepetizerFlutterItemData(image: 'https://img/b.jpg'),
            ),
          ],
        ),
      ]);
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      await bloc.refresh();
      expect(bloc.items, hasLength(1));
      expect(bloc.items.single.data!.description, '留下');
      bloc.dispose();
    });

    test('a refresh that comes back empty keeps the previous cards', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[_columnCard(description: '旧的')],
          nextPageUrl: 'page-2',
        ),
        const EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[],
          nextPageUrl: 'page-9',
        ),
      ]);
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      await bloc.refresh();
      await bloc.refresh();
      expect(bloc.items, hasLength(1));
      expect(bloc.items.single.data!.description, '旧的');
      expect(bloc.nextPageUrl, 'page-9');
      bloc.dispose();
    });

    test('a failed page records the error and forgets the load status', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        const EyepetizerFlutterBaseListData(code: 200),
      ])..failure = const EyepetizerFlutterException('网络连接失败，请检查网络');
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      await bloc.refresh();
      expect(bloc.items, isEmpty);
      expect(bloc.error, isA<EyepetizerFlutterException>());
      expect(bloc.loadStatus, EyepetizerFlutterLoadStatus.init);
      expect(bloc.loading, isFalse);
      bloc.dispose();
    });

    test('a load that is already running is not stacked', () async {
      final fake = _FakeCommunityRepository(<EyepetizerFlutterBaseListData>[
        const EyepetizerFlutterBaseListData(code: 200),
      ]);
      final bloc = EyepetizerFlutterCommunityBloc(repository: fake);
      final first = bloc.refresh();
      final second = bloc.loadMore();
      await Future.wait(<Future<void>>[first, second]);
      expect(fake.requestedNextPageUrls, hasLength(1));
      bloc.dispose();
    });
  });

  group('local cache database', () {
    test('the table DDL matches the source', () {
      final provider = EyepetizerFlutterBaseListProvider(
        database: _FakeDatabase(),
      );
      expect(
        provider.tableSql(),
        'create table base_list (_id integer primary key autoincrement,'
        'tag text not null,data text not null)',
      );
      expect(EyepetizerFlutterBaseListProvider.tabName, 'base_list');
      expect(EyepetizerFlutterBaseListProvider.idColumn, '_id');
      expect(EyepetizerFlutterBaseListProvider.tagColumn, 'tag');
      expect(EyepetizerFlutterBaseListProvider.dataColumn, 'data');
    });

    test('the table probe is the verbatim Sqlite_master query', () async {
      final database = _FakeDatabase();
      final provider = EyepetizerFlutterBaseListProvider(database: database);
      expect(await provider.checkTableExists('base_list'), isTrue);
      expect(
        database.rawQueries.single,
        "select * from Sqlite_master where type = 'table' and name = 'base_list'",
      );
    });

    test('a missing table is created with tableSql before the first write', () async {
      final database = _FakeDatabase(tableExists: false);
      final provider = EyepetizerFlutterBaseListProvider(database: database);
      await provider.insert(
        EyepetizerFlutterStrings.recommend,
        const EyepetizerFlutterBaseListData(code: 200),
      );
      expect(database.executedSql.single, provider.tableSql());
      expect(database.deletedTagArguments, isEmpty);
      expect(database.inserts.single['tag'], 'recommend');
    });

    test('writing a tag deletes the tag row first and stores JSON', () async {
      final database = _FakeDatabase();
      final provider = EyepetizerFlutterBaseListProvider(database: database);
      await provider.insert(
        EyepetizerFlutterStrings.discover,
        EyepetizerFlutterBaseListData(
          code: 200,
          itemList: <EyepetizerFlutterItem>[
            EyepetizerFlutterItem(
              type: 'banner',
              data: EyepetizerFlutterItemData(image: 'https://img/b.jpg'),
            ),
          ],
          nextPageUrl: 'page-2',
        ),
      );
      expect(database.deletedTagArguments.single, 'discover');
      final stored = jsonDecode(database.inserts.single['data']! as String);
      expect(stored, isA<Map<String, dynamic>>());
      expect(stored['code'], 200);
      expect(stored['nextPageUrl'], 'page-2');
    });

    test('query returns null when the tag has no row', () async {
      final database = _FakeDatabase();
      final provider = EyepetizerFlutterBaseListProvider(database: database);
      expect(await provider.query(EyepetizerFlutterStrings.daily), isNull);
    });

    test('query decodes the stored page back into a BaseListData', () async {
      final database = _FakeDatabase()
        ..queryRows = <Map<String, Object?>>[
          <String, Object?>{
            '_id': 1,
            'tag': EyepetizerFlutterStrings.recommend,
            'data': jsonEncode(<String, Object?>{
              'code': 200,
              'itemList': <Object?>[
                <String, Object?>{
                  'type': 'communityColumnsCard',
                  'data': <String, Object?>{'description': '缓存的一张图'},
                },
              ],
              'nextPageUrl': 'page-2',
            }),
          },
        ];
      final provider = EyepetizerFlutterBaseListProvider(database: database);
      final page = await provider.query(EyepetizerFlutterStrings.recommend);
      expect(page!.code, 200);
      expect(page.itemList.single.data!.description, '缓存的一张图');
      expect(page.nextPageUrl, 'page-2');
    });

    test('the join helper keeps the source concatenation quirk', () {
      expect(
        EyepetizerFlutterSqliteHelper.join(
          '/data/user/0/app/databases',
          EyepetizerFlutterSqliteHelper.databaseName,
        ),
        '/data/user/0/app/databaseseyepetizer_flutter.db',
      );
      expect(EyepetizerFlutterSqliteHelper.databaseName, 'eyepetizer_flutter.db');
      expect(EyepetizerFlutterSqliteHelper.version, 1);
    });

    test('the three cache tags are the source Strings values', () {
      expect(EyepetizerFlutterStrings.discover, 'discover');
      expect(EyepetizerFlutterStrings.daily, 'daily');
      expect(EyepetizerFlutterStrings.recommend, 'recommend');
      expect(EyepetizerFlutterStrings.cacheTags, <String>[
        'discover',
        'daily',
        'recommend',
      ]);
    });
  });

  group('preference storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('putObject stores JSON under the source user_data key', () async {
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        <String, Object?>{
          'error': 0,
          'member': <String, Object?>{'uid': 7, 'nick': '阿开'},
        },
      );
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(EyepetizerFlutterPrefsKey.userData),
        jsonEncode(<String, Object?>{
          'error': 0,
          'member': <String, Object?>{'uid': 7, 'nick': '阿开'},
        }),
      );
      expect(EyepetizerFlutterPrefsKey.userData, 'user_data');
    });

    test('getObj maps the stored map back into a Login', () async {
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        EyepetizerFlutterLogin(
          error: 0,
          msg: 'ok',
          member: EyepetizerFlutterMember.fromJson(<String, dynamic>{
            'uid': 7,
            'nick': '阿开',
          }),
        ).toJson(),
      );
      final login = await EyepetizerFlutterPrefsUtil.getObj<EyepetizerFlutterLogin>(
        EyepetizerFlutterPrefsKey.userData,
        EyepetizerFlutterLogin.fromJson,
      );
      expect(login!.error, 0);
      expect(login.member!.uid, 7);
      expect(login.member!.nick, '阿开');
    });

    test('a null object is stored as an empty string and reads back null', () async {
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        null,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(EyepetizerFlutterPrefsKey.userData), '');
      expect(
        await EyepetizerFlutterPrefsUtil.getObject(
          EyepetizerFlutterPrefsKey.userData,
        ),
        isNull,
      );
    });

    test('getObj returns the default when nothing is stored', () async {
      final login = await EyepetizerFlutterPrefsUtil.getObj<EyepetizerFlutterLogin>(
        EyepetizerFlutterPrefsKey.userData,
        EyepetizerFlutterLogin.fromJson,
        defaultValue: const EyepetizerFlutterLogin(error: -1),
      );
      expect(login!.error, -1);
    });

    test('remove and clear drop the stored login', () async {
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        <String, Object?>{'error': 0},
      );
      await EyepetizerFlutterPrefsUtil.remove(EyepetizerFlutterPrefsKey.userData);
      expect(
        await EyepetizerFlutterPrefsUtil.getObject(
          EyepetizerFlutterPrefsKey.userData,
        ),
        isNull,
      );
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        <String, Object?>{'error': 0},
      );
      await EyepetizerFlutterPrefsUtil.clear();
      expect(
        await EyepetizerFlutterPrefsUtil.getObject(
          EyepetizerFlutterPrefsKey.userData,
        ),
        isNull,
      );
    });

    test('save and get handle a plain string', () async {
      await EyepetizerFlutterPrefsUtil.save<String>('token', 'abc');
      expect(await EyepetizerFlutterPrefsUtil.get('token'), 'abc');
    });

    test('object lists round-trip through json encoding', () async {
      await EyepetizerFlutterPrefsUtil.putObjectList('devices', <Object?>[
        <String, Object?>{'udid': 'a'},
        <String, Object?>{'udid': 'b'},
      ]);
      final list = await EyepetizerFlutterPrefsUtil
          .getObjList<Map<String, dynamic>>('devices', (json) => json);
      expect(list, hasLength(2));
      expect(list.first['udid'], 'a');
      expect(list.last['udid'], 'b');
    });

    test('an absent object list falls back to the default', () async {
      final list = await EyepetizerFlutterPrefsUtil
          .getObjList<Map<String, dynamic>>('missing', (json) => json);
      expect(list, isEmpty);
    });
  });

  group('pure screen logic', () {
    test('login validation reports the source messages in order', () {
      expect(
        EyepetizerFlutterLoginPageState.validate(phone: '', password: 'x'),
        '手机号不能为空',
      );
      expect(
        EyepetizerFlutterLoginPageState.validate(phone: '138', password: ''),
        '密码不能为空',
      );
      expect(
        EyepetizerFlutterLoginPageState.validate(phone: '138', password: 'x'),
        isNull,
      );
    });

    test('register validation reports the source messages in order', () {
      expect(
        EyepetizerFlutterRegisterPageState.validate(
          phone: '',
          password: 'x',
          verificationCode: '1',
        ),
        '手机号不能为空',
      );
      expect(
        EyepetizerFlutterRegisterPageState.validate(
          phone: '138',
          password: '',
          verificationCode: '1',
        ),
        '密码不能为空',
      );
      expect(
        EyepetizerFlutterRegisterPageState.validate(
          phone: '138',
          password: 'x',
          verificationCode: '',
        ),
        '验证码不能为空',
      );
      expect(
        EyepetizerFlutterRegisterPageState.validate(
          phone: '138',
          password: 'x',
          verificationCode: '1',
        ),
        isNull,
      );
    });

    test('the countdown label follows the source remaining/tick rule', () {
      expect(
        EyepetizerFlutterCountdownButtonState.labelFor(period: 60, tick: 1),
        '59秒',
      );
      expect(
        EyepetizerFlutterCountdownButtonState.labelFor(period: 60, tick: 59),
        '1秒',
      );
      expect(
        EyepetizerFlutterCountdownButtonState.labelFor(period: 60, tick: 60),
        '发送验证码',
      );
      expect(
        EyepetizerFlutterCountdownButtonState.labelFor(period: 60, tick: 61),
        '发送验证码',
      );
    });

    test('the footer labels are the source strings', () {
      expect(
        EyepetizerFlutterFooterViewState.labelFor(
          EyepetizerFlutterLoadStatus.loading,
        ),
        '加载中...',
      );
      expect(
        EyepetizerFlutterFooterViewState.labelFor(
          EyepetizerFlutterLoadStatus.completed,
        ),
        '加载完成',
      );
      expect(
        EyepetizerFlutterFooterViewState.labelFor(
          EyepetizerFlutterLoadStatus.init,
        ),
        '',
      );
      expect(EyepetizerFlutterFooterViewState.labelFor(null), '');
    });

    test('the load status enum has exactly the source members', () {
      expect(
        EyepetizerFlutterLoadStatus.values,
        <EyepetizerFlutterLoadStatus>[
          EyepetizerFlutterLoadStatus.init,
          EyepetizerFlutterLoadStatus.loading,
          EyepetizerFlutterLoadStatus.completed,
        ],
      );
    });

    test('date formatting matches the source intl patterns', () {
      final moment = DateTime(2020, 1, 2, 12, 34, 56).millisecondsSinceEpoch;
      expect(EyepetizerFlutterDateUtil.format(moment), '34:56');
      expect(EyepetizerFlutterDateUtil.getDuration(0), '00:00');
      expect(EyepetizerFlutterDateUtil.getDuration(59), '00:59');
      expect(EyepetizerFlutterDateUtil.getDuration(60), '01:00');
      expect(EyepetizerFlutterDateUtil.getDuration(3599), '59:59');
      expect(EyepetizerFlutterDateUtil.getDuration(3600), '1:00:00');
      expect(EyepetizerFlutterDateUtil.getDuration(3661), '1:01:01');
      expect(EyepetizerFlutterDateUtil.formatBirthdaySeconds(null), '');
      expect(EyepetizerFlutterDateUtil.formatBirthdaySeconds(0), '1970/01/01');
    });
  });

  group('widgets', () {
    testWidgets('the attention tab is the source placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EyepetizerFlutterAttentionPage()),
      );
      final label = tester.widget<Text>(find.text('Attention'));
      expect(label.style!.fontSize, 60);
      expect(label.style!.color, Colors.pink);
    });

    testWidgets('the countdown button shows its text then the remaining seconds', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EyepetizerFlutterCountdownButton(
              text: '获取验证码',
              period: 2,
              interval: 1,
              onCountDownStart: () => taps++,
            ),
          ),
        ),
      );
      expect(find.text('获取验证码'), findsOneWidget);
      await tester.tap(find.text('获取验证码'));
      await tester.pump();
      expect(taps, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1秒'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('发送验证码'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('发送验证码'), findsOneWidget);
    });
  });
}
