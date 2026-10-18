import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';

/// Ports PicaComic's `RankingData`.
class RankingData {
  /// key is sent to the source, value is displayed to the user.
  final Map<String, String> options;

  final Future<Res<List<BaseComic>>> Function(String option, int page) load;

  const RankingData({required this.options, required this.load});
}
