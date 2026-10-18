import 'package:dashboard/features/comic/picacomic/network/hitomi_models.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';
import 'package:dio/dio.dart';

/// Ports PicaComic lib/network/hitomi_network/image.dart: the `gg.js` derived
/// image url builder used by hitomi.la.
class GG {
  GG({Dio? dio}) : dio = dio ?? createSourceDio();

  final Dio dio;

  List<String> numbers = [];
  int initialG = 1;
  String? b;

  int mm(int g) {
    if (numbers.contains(g.toString())) {
      return ~initialG & 1;
    }
    return initialG;
  }

  /// image.dart:22-31 — takes the last three hex chars of a hash and swaps the
  /// last pair with the third-from-last.
  static String s(String h) {
    final exp = RegExp(r'(..)(.)$');
    final m = exp.firstMatch(h);
    if (m != null) {
      final g = int.parse(m.group(2)! + m.group(1)!, radix: 16);
      return g.toString();
    }
    return '';
  }

  /// gg.js is stable for a short time; mirrors the 100 ms source cache.
  DateTime? cacheTime;
  String? cacheB;
  List<String>? cacheNumbers;
  int cacheInitialG = 1;

  Future<void> getGg(String galleryId) async {
    if (cacheTime != null &&
        DateTime.now().millisecondsSinceEpoch -
                cacheTime!.millisecondsSinceEpoch <
            100) {
      numbers = cacheNumbers!;
      b = cacheB!;
      initialG = cacheInitialG;
      return;
    }
    final response = await dio.get<String>(
      'https://ltn.hitomi.la/gg.js?_=1683939645979',
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'User-Agent': webUserAgent,
          'Referer': 'https://hitomi.la/reader/$galleryId.html',
        },
      ),
    );
    final data = '${response.data}';
    numbers = [
      for (final match in RegExp(r'(?<=case )\d+').allMatches(data))
        match.group(0)!,
    ];
    b = RegExp(r"(?<=b: ')\d+").firstMatch(data)![0];
    initialG = int.parse(RegExp(r'(?<=var o = )[0-9]+').firstMatch(data)![0]!);
    cacheTime = DateTime.now();
    cacheB = b;
    cacheNumbers = numbers;
    cacheInitialG = initialG;
  }

  String subdomainFromUrl(String url, String? base) {
    var retval = 'b';
    if (base != null) {
      retval = base;
    }
    final m = RegExp(r'/[0-9a-f]{61}([0-9a-f]{2})([0-9a-f])').firstMatch(url);
    if (m == null) {
      return 'a';
    }
    final g = int.parse(m[2]! + m[1]!, radix: 16);
    retval = String.fromCharCode(97 + mm(g)) + retval;
    return retval;
  }

  String fullPathFromHash(String hash) => '$b/${GG.s(hash)}/$hash';

  /// image.dart:91-97 — `realFullPathFromHash`.
  String realFullPathFromHash(String hash) {
    final regex = RegExp(r'^.*(..)(.)$');
    return regex.stringMatch(hash)!.replaceAllMapped(
      regex,
      (match) => '${match.group(2)}/${match.group(1)}/$hash',
    );
  }

  String urlFromUrl(String url, String? base) => url.replaceFirst(
    RegExp(r'//..?\.hitomi\.la/'),
    '//${subdomainFromUrl(url, base)}.hitomi.la/',
  );

  String urlFromHash(HitomiFile image, String? dir, String? ext) {
    ext ??= dir ??= image.name.split('.').last;
    dir ??= 'images';
    if (dir.contains('small')) {
      return 'https://a.hitomi.la/$dir/${realFullPathFromHash(image.hash)}.$ext';
    }
    return 'https://a.hitomi.la/$dir/${fullPathFromHash(image.hash)}.$ext';
  }

  Future<String> urlFromUrlFromHash(
    String galleryId,
    HitomiFile image,
    String? dir,
    String? ext, [
    String subDomainBase = 'a',
  ]) async {
    await getGg(galleryId);
    return urlFromUrl(urlFromHash(image, dir, ext), subDomainBase);
  }
}
