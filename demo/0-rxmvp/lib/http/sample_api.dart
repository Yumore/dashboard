import 'base_api.dart';

class RoomApi extends BaseApi {
  RoomApi() : super('/app/api/room/list');
}

class StartLiveApi extends BaseApi {
  StartLiveApi() : super('/app/api/room/start', httpMethod: HttpMethod.post);

  set setId(int roomId) => params['id'] = '$roomId';
}
