import 'dio_new.dart';

/// Response 解析
abstract class HttpTransformer {
  DioHttpResponse parse(Response response);
}
