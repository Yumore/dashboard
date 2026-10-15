import 'package:dashboard/features/comic/u17_source.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('U17 source maps list, chapters and images', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final Object payload;
          if (options.path.endsWith('/list/conditionScreenlists')) {
            payload = {
              'comics': [
                {
                  'comic_id': 17,
                  'name': '示例漫画',
                  'cover': 'https://example.com/a.jpg',
                },
              ],
            };
          } else if (options.path.endsWith('/comic/detail_static_new')) {
            payload = {
              'comic': {
                'comic_id': '17',
                'name': '完整名称',
                'description': '详细介绍',
                'author': {'name': '作者'},
                'theme_ids': ['奇幻'],
                'last_update_time': 1600000000,
              },
              'chapter_list': [
                {'chapter_id': '31', 'name': '第一话'},
                {'chapter_id': '32', 'name': '付费话', 'has_locked_image': 1},
              ],
            };
          } else {
            payload = {
              'image_list': [
                {'location': 'https://example.com/1.jpg'},
                {
                  'location': 'file:///private/image.jpg',
                  'img50': 'https://example.com/2.jpg',
                },
              ],
            };
          }
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'data': {'stateCode': 1, 'returnData': payload},
              },
              statusCode: 200,
            ),
          );
        },
      ),
    );
    final source = U17Source(dio: dio);
    expect((await source.list()).single.name, '示例漫画');
    expect((await source.chapters(17)).first.id, 31);
    final detail = await source.details(const U17Comic(id: 17, name: '搜索名称'));
    expect(detail.comic.name, '完整名称');
    expect(detail.comic.author, '作者');
    expect(detail.comic.tags, ['奇幻']);
    expect(detail.chapters.last.locked, isTrue);
    expect((await source.images(31)).map((uri) => uri.path), [
      '/1.jpg',
      '/2.jpg',
    ]);
    source.dispose();
  });
}
