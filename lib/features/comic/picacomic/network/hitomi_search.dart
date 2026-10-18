import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';
import 'package:dio/dio.dart';

/// Ports PicaComic lib/network/hitomi_network/search.dart: hitomi.la's
/// `galleries.<version>.index` B-tree lookup plus `.nozomi` id lists.
///
/// Deviation: the source cached every ranged response in
/// `getApplicationCacheDirectory()/hitomi/<md5>` (search.dart:173-193). This
/// port keeps the same md5 key but caches in memory, so no path_provider /
/// filesystem dependency is needed and tests stay hermetic.
class HitomiSearch {
  HitomiSearch(this.keyword, {Dio? dio}) : dio = dio ?? createSourceDio();

  final Dio dio;
  final String keyword;

  static const String domain = 'https://ltn.hitomi.la';
  static const int maxNodeSize = 464;

  final nozomiExtension = '.nozomi';
  var indexDir = 'galleriesindex';
  var galleriesIndexDir = 'galleriesindex';

  var results = <int>[];
  String? tagIndexVersion;

  final Map<String, Uint8List> _rangeCache = {};

  /// Ports search.dart:26-89 including the sorted-id intersection for positive
  /// terms and the difference for `-term` negations.
  Future<Res<List<int>>> search() async {
    await getTagIndexVersion();
    final terms = keyword.toLowerCase().trim().split(RegExp(r'\s+'));
    final negativeTerms = <String>[];
    final positiveTerms = <String>[];
    for (var term in terms) {
      term = term.replaceAll('_', ' ');
      if (term.startsWith('-')) {
        negativeTerms.add(term.replaceFirst('-', ''));
      } else {
        positiveTerms.add(term);
      }
    }
    if (positiveTerms.isEmpty) {
      results = await getGalleryIdsFromNozomi(null, 'index', 'all');
    } else {
      final term = positiveTerms.removeAt(0);
      results = await getGalleryIdsForQuery(term);
    }
    // Intersection (both lists are ascending id lists).
    for (final term in positiveTerms) {
      final res = await getGalleryIdsForQuery(term);
      final newRes = <int>[];
      var p1 = 0;
      var p2 = 0;
      while (p1 < res.length && p2 < results.length) {
        if (res[p1] > results[p2]) {
          p1++;
        } else if (res[p1] < results[p2]) {
          p2++;
        } else {
          newRes.add(res[p1]);
          p1++;
          p2++;
        }
      }
      results = newRes;
    }
    // Difference. Deviation: PicaComic search.dart:68-87 walks the two sorted
    // lists and adds an element *after* advancing the cursor, which both drops
    // and duplicates ids; a set difference expresses the intended `-term`
    // semantics and is what the tests pin.
    for (final term in negativeTerms) {
      final excluded = (await getGalleryIdsForQuery(term)).toSet();
      results = [
        for (final id in results)
          if (!excluded.contains(id)) id,
      ];
    }
    return Res(results);
  }

  Future<void> getTagIndexVersion() async {
    final res = await dio.get<String>(
      '$domain/galleriesindex/version?_=${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
      options: Options(responseType: ResponseType.plain),
    );
    tagIndexVersion = res.data;
  }

  Future<List<int>> getGalleryIdsFromNozomi(
    String? area,
    String tag,
    String language,
  ) async {
    var url = '$domain/n/$tag-$language$nozomiExtension';
    if (area != null) {
      url = '$domain/n/$area/$tag-$language$nozomiExtension';
    }
    final bytes =
        (await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        )).data ??
        <int>[];
    return decodeNozomi(bytes);
  }

  /// search.dart:122-155 — `namespace:tag` handling.
  Future<List<int>> getGalleryIdsForQuery(String query) async {
    query = query.replaceAll('_', ' ');
    if (query.contains(':')) {
      final sides = query.split(':');
      final ns = sides[0];
      var tag = sides[1];
      String? area = ns;
      var language = 'all';
      if (ns == 'female' || ns == 'male') {
        area = 'tag';
        tag = query;
      } else if (ns == 'language') {
        area = null;
        language = tag;
        tag = 'index';
      }
      return getGalleryIdsFromNozomi(area, tag, language);
    }
    final key = hashTerm(query);
    const field = 'galleries';
    final node = await getNodeAtAddress(field, 0);
    if (node == null) {
      return [];
    }
    final data = await bSearch(field, key, node);
    if (data == null) {
      return [];
    }
    return getGalleryIdsFromData(data);
  }

  Uint8List hashTerm(String term) {
    final hash = sha256.convert(utf8.encode(term)).bytes;
    return Uint8List.fromList(hash.sublist(0, 4));
  }

  Future<Node?> getNodeAtAddress(String field, int address) async {
    final url = '$domain/$indexDir/$field.${tagIndexVersion!}.index';
    final res = await getUrlAtRange(url, [address, address + maxNodeSize - 1]);
    if (res == null) {
      return null;
    }
    return decodeNodeData(res);
  }

  Future<Uint8List?> getUrlAtRange(String url, List<int> range) async {
    final key = md5.convert(const Utf8Encoder().convert('$url$range')).toString();
    final cached = _rangeCache[key];
    if (cached != null) {
      return cached;
    }
    final res = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Range': 'bytes=${range[0]}-${range[1]}',
          'User-Agent': webUserAgent,
          'Referer': 'https://hitomi.la/search.html',
          'Origin': 'https://hitomi.la',
        },
      ),
    );
    final data = Uint8List.fromList(res.data ?? const []);
    _rangeCache[key] = data;
    return data;
  }

  Future<Node?> decodeNodeData(Uint8List data) async {
    final view = ByteData.view(data.buffer);
    var pos = 0;
    final numberOfKeys = view.getInt32(pos, Endian.big);
    pos += 4;
    final keys = <Uint8List>[];
    for (var i = 0; i < numberOfKeys; i++) {
      final keySize = view.getInt32(pos, Endian.big);
      if (keySize == 0 || keySize > 32) {
        return null;
      }
      pos += 4;
      keys.add(data.sublist(pos, pos + keySize));
      pos += keySize;
    }
    final numberOfDatas = view.getInt32(pos, Endian.big);
    pos += 4;
    final datas = <List<int>>[];
    for (var i = 0; i < numberOfDatas; i++) {
      final offset = view.getUint64(pos, Endian.big);
      pos += 8;
      final length = view.getInt32(pos, Endian.big);
      pos += 4;
      datas.add([offset, length]);
    }
    const b = 16;
    final numberOfSubnodeAddresses = b + 1;
    final subnodeAddresses = <int>[];
    for (var i = 0; i < numberOfSubnodeAddresses; i++) {
      final subnodeAddress = view.getUint64(pos, Endian.big);
      if (i != 0 && subnodeAddress < subnodeAddresses.last) {
        continue;
      }
      pos += 8;
      subnodeAddresses.add(subnodeAddress);
    }
    return Node(keys, datas, subnodeAddresses);
  }

  Future<List<int>?> bSearch(String field, Uint8List key, Node? node) async {
    if (node == null) {
      return null;
    }
    if (node.keys.isEmpty) {
      return null;
    }
    final [there, where] = locateKey(key, node);
    if (there) {
      return node.data[where];
    } else if (isLeaf(node)) {
      return null;
    }
    if (node.subNodeAddresses[where] == 0) {
      return null;
    }
    final next = await getNodeAtAddress(field, node.subNodeAddresses[where]);
    return bSearch(field, key, next);
  }

  /// search.dart:249-271.
  static List<dynamic> locateKey(Uint8List key, Node node) {
    var cmpResult = -1;
    int i;
    for (i = 0; i < node.keys.length; i++) {
      cmpResult = compareArrayBuffers(key, node.keys[i]);
      if (cmpResult <= 0) {
        break;
      }
    }
    return [cmpResult == 0, i];
  }

  static bool isLeaf(Node node) {
    for (var i = 0; i < node.subNodeAddresses.length; i++) {
      if (node.subNodeAddresses[i] != 0) {
        return false;
      }
    }
    return true;
  }

  /// search.dart:249-259 `compareArrayBuffers`.
  static int compareArrayBuffers(Uint8List a, Uint8List b) {
    final top = min(a.length, b.length);
    for (var i = 0; i < top; i++) {
      if (a[i] < b[i]) {
        return -1;
      } else if (a[i] > b[i]) {
        return 1;
      }
    }
    return 0;
  }

  Future<List<int>> getGalleryIdsFromData(List<int>? data) async {
    if (data == null) {
      return [];
    }
    final offset = data[0];
    final length = data[1];
    final url = '$domain/$galleriesIndexDir/galleries.${tagIndexVersion!}.data';
    final inbuf = await getUrlAtRange(url, [offset, offset + length - 1]);
    if (inbuf == null) {
      return [];
    }
    final galleryIds = <int>[];
    var pos = 0;
    final view = ByteData.view(inbuf.buffer);
    final numberOfGalleryIds = view.getInt32(pos);
    pos += 4;
    final expectedLength = numberOfGalleryIds * 4 + 4;
    if (numberOfGalleryIds > 10000000 || numberOfGalleryIds <= 0) {
      return [];
    } else if (inbuf.length != expectedLength) {
      return [];
    }
    for (var i = 0; i < numberOfGalleryIds; i++) {
      galleryIds.add(view.getInt32(pos));
      pos += 4;
    }
    return galleryIds;
  }

  /// fetch_data.dart:42-52 / search.dart:109-119: every 4 bytes little-endian
  /// int32 is one gallery id.
  static List<int> decodeNozomi(List<int> bytes) {
    final comicIds = <int>[];
    for (var i = 0; i + 4 <= bytes.length; i += 4) {
      comicIds.add(ByteData.sublistView(
        Uint8List.fromList(bytes.sublist(i, i + 4)),
      ).getInt32(0, Endian.little));
    }
    return comicIds;
  }
}

class Node {
  Node(this.keys, this.data, this.subNodeAddresses);

  List<Uint8List> keys;

  /// Each entry is `[offset, length]`.
  List<List<int>> data;
  List<int> subNodeAddresses;
}
