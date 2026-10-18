import 'package:html/dom.dart';

/// HTML → 模型解析器的统一接口。
abstract class AnimeOneBasicParser<T> {
  /// 把页面文档解析成模型，站点结构变化时不应抛异常。
  T parse(Document document);
}
