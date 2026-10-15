import 'package:dashboard/features/reading/chapter_text_cleaner.dart';
import 'package:http/http.dart' as http;

class ReadingWebSource {
  ReadingWebSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final ChapterTextCleaner _cleaner = const ChapterTextCleaner();

  Future<String> load(Uri url, {String replaceRule = ''}) async {
    if (!<String>['http', 'https'].contains(url.scheme)) {
      throw const FormatException('章节地址必须使用 HTTP/HTTPS');
    }
    final response = await _client
        .get(url)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200)
      throw Exception('章节请求失败：HTTP ${response.statusCode}');
    final text = _cleaner.clean(response.body, replaceRule: replaceRule);
    if (text.isEmpty) throw const FormatException('章节内容为空');
    return text;
  }

  void dispose() => _client.close();
}
