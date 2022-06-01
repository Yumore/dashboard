import 'http_exceptions.dart';

class DioHttpResponse {
  late bool ok;
  dynamic? data;
  HttpException? error;

  DioHttpResponse._internal({this.ok = false});

  DioHttpResponse.success(this.data) {
    this.ok = true;
  }

  DioHttpResponse.failure({String? errorMsg, int? errorCode}) {
    this.error = BadRequestException(message: errorMsg, code: errorCode);
    this.ok = false;
  }

  DioHttpResponse.failureFormResponse({dynamic? data}) {
    this.error = BadResponseException(data);
    this.ok = false;
  }

  DioHttpResponse.failureFromError([HttpException? error]) {
    this.error = error ?? UnknownException();
    this.ok = false;
  }
}
