import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/eh_models.dart';

/// Ports `_EhentaiGalleriesLoader` from
/// PicaComic lib/comic_source/built_in/ehentai.dart:574.
///
/// e-hentai list pages are cursor based (`#dnext`); this pager caches every
/// loaded page so that arbitrary page indices can be requested.
class EhGalleriesPager {
  EhGalleriesPager({
    required this.firstPageLoader,
    required this.nextPageLoader,
  });

  final Future<Res<EhGalleries>> Function() firstPageLoader;
  final Future<Res<EhGalleries>> Function(String url) nextPageLoader;

  String? nextPage;
  final List<List<BaseComic>> cache = [];

  bool get hasMore => nextPage != null;

  /// [page] starts at 1.
  Future<Res<List<BaseComic>>> load(int page) async {
    if (page == 1 || cache.isEmpty) {
      final res = await _loadFirstPage();
      if (res.error) return Res.fromErrorRes(res);
    }
    final index = page - 1;
    while (index >= cache.length) {
      final res = await _loadNextPage();
      if (res.error) return Res.fromErrorRes(res);
    }
    return Res(cache[index]);
  }

  Future<Res<void>> _loadFirstPage() async {
    final res = await firstPageLoader();
    if (res.error) return Res.fromErrorRes(res);
    cache
      ..clear()
      ..add(res.data.galleries);
    nextPage = res.data.next;
    return const Res(null);
  }

  Future<Res<void>> _loadNextPage() async {
    final next = nextPage;
    if (next == null) {
      return const Res(null, errorMessage: 'No more data');
    }
    final res = await nextPageLoader(next);
    if (res.error) return Res.fromErrorRes(res);
    cache.add(res.data.galleries);
    nextPage = res.data.next;
    return const Res(null);
  }
}
