import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_http.dart';

/// `lib/http/repository/detail_repository.dart`.
///
/// The video-detail screen that also consumes `getVideoDetail` belongs to the
/// sibling port under `lib/features/movie/eyepetizer/`, which this module must
/// not import. The picture-detail page needs the same call — an `ugc_picture`
/// post is served by the video endpoint with `resourceType` naming the kind —
/// so this is the module's own minimal copy of that one request rather than a
/// second owner of the video screen.
class EyepetizerFlutterDetailRepository {
  EyepetizerFlutterDetailRepository({EyepetizerFlutterHttp? http})
    : _http = http ?? EyepetizerFlutterHttp();

  final EyepetizerFlutterHttp _http;

  EyepetizerFlutterHttp get http => _http;

  /// 获取视频详情数据 — `GET /api/v2/video/<id>?resourceType=<kind>`.
  Future<EyepetizerFlutterDetail> getVideoDetail(
    int id, {
    String? resourceType,
  }) async {
    final result = await _http.request(
      '${EyepetizerFlutterEndpoint.videoDetail}$id',
      data: <String, dynamic>{'resourceType': resourceType},
      method: 'GET',
    );
    return EyepetizerFlutterDetail.fromJson(result);
  }

  /// 获取相关视频数据 — kept for parity with the source repository even though
  /// the picture-detail page does not call it.
  Future<EyepetizerFlutterBaseListData> getRelateVideo(int id) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.relateVideo,
      data: <String, dynamic>{'id': id},
      method: 'GET',
    );
    return EyepetizerFlutterBaseListData.fromJson(result);
  }

  void dispose() => _http.dispose();
}
