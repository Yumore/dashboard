import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_http.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_home_parser.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_model.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_upload_picture.dart';
import 'package:dio/dio.dart';

/// `lib/http/repository/person_repository.dart`.
///
/// Four surfaces share `GET /api/v5/userInfo/tab`:
/// * the person header (`id` + `userType`),
/// * each person-home tab (an absolute `apiUrl` passed as the target URL),
/// * image upload (`POST /api/tools/image`, the only multipart call),
/// * saving the profile (`POST /api/v5/userInfo/edit`).
class EyepetizerFlutterPersonRepository {
  EyepetizerFlutterPersonRepository({EyepetizerFlutterHttp? http})
    : _http = http ?? EyepetizerFlutterHttp();

  final EyepetizerFlutterHttp _http;

  EyepetizerFlutterHttp get http => _http;

  /// 获取个人主页数据.
  ///
  /// `userType` is `NORMAL` for one's own profile and `PGC` otherwise; the
  /// source chose it from the `isMyself` flag the page derived from the
  /// route argument's length.
  Future<EyepetizerFlutterPersonMainModel> getPersonMainPageData(
    int id,
    bool isMyself,
  ) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.personHomepage,
      data: <String, dynamic>{
        'id': id,
        'userType': isMyself ? 'NORMAL' : 'PGC',
      },
      method: 'GET',
    );
    return EyepetizerFlutterPersonMainModel.fromJson(result);
  }

  /// 获取个人首页数据 — the tab's own `apiUrl` is the whole request.
  Future<EyepetizerFlutterBaseListData> getPersonHomePageData(
    String targetUrl,
  ) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.personHomepage,
      targetUrl: targetUrl,
      method: 'GET',
    );
    return EyepetizerFlutterPersonHomeParser.parse(result);
  }

  /// 上传图片.
  ///
  /// The multipart part name is `file`; the filename is whatever follows the
  /// last `/` in the picked path. The source also computed the extension into
  /// an unused local, so the port does not.
  Future<EyepetizerFlutterUploadPicture> uploadPicture(String filePath) async {
    final name = filePath.substring(filePath.lastIndexOf('/') + 1);
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(
        filePath,
        filename: name,
        contentType: DioMediaType('image', '*'),
      ),
    });
    final result = await _http.request(
      EyepetizerFlutterEndpoint.uploadPicture,
      formData: formData,
      method: 'POST',
    );
    return EyepetizerFlutterUploadPicture.fromJson(result);
  }

  /// 保存个人资料.
  ///
  /// The form's `男`/`女` is translated to the API's `male`/`female` — every
  /// other value (including an empty field) is sent as `female`. Named
  /// parameters replace the source's nine positional strings so the birthday
  /// and the name cannot be transposed at the call site.
  Future<EyepetizerFlutterLogin> savePersonData({
    required String cover,
    required String avatar,
    required String name,
    required String gender,
    required String birthday,
    required String city,
    required String university,
    required String job,
    required String description,
  }) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.editUserData,
      data: <String, dynamic>{
        'nick': name,
        'gender': normaliseGender(gender),
        'birthday': birthday,
        'city': city,
        'university': university,
        'job': job,
        'description': description,
        'avatar': avatar,
        'cover': cover,
      },
      method: 'POST',
    );
    return EyepetizerFlutterLogin.fromJson(result);
  }

  /// `gender == "男" ? "male" : "female"`, exactly as the source wrote it.
  static String normaliseGender(String gender) =>
      gender == '男' ? 'male' : 'female';

  void dispose() => _http.dispose();
}
