import 'package:dashboard/features/live/live_channel.dart';
import 'package:dashboard/features/live/live_playlist_parser.dart';
import 'package:http/http.dart' as http;

class LivePlaylistRepository {
  LivePlaylistRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  final LivePlaylistParser _parser = const LivePlaylistParser();

  Future<List<LiveChannel>> load(Uri source) async {
    if (source.scheme != 'http' && source.scheme != 'https') {
      throw const FormatException('仅支持 HTTP/HTTPS 订阅地址');
    }
    final response = await _client
        .get(source)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('订阅请求失败：HTTP ${response.statusCode}');
    }
    final channels = _parser.parse(response.body);
    if (channels.isEmpty) throw const FormatException('订阅中没有可播放频道');
    return channels;
  }

  void dispose() => _client.close();
}
