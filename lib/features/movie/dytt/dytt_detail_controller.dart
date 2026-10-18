import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_error_message.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:flutter/foundation.dart';

/// 详情页控制器：用列表项里的 `id`/`categoryId` 拉完整详情。
///
/// 源工程从列表项直接进详情，不再请求；列表行没有简介和下载地址，
/// 所以宿主这里按 `fetchMovieDetail(categoryId, movieDetailId)` 补一次。
class DyttDetailController extends ChangeNotifier {
  DyttDetailController({
    required this.api,
    required this.categoryId,
    required this.movieId,
    DyttMovieDetail? initial,
  }) : _movie = initial;

  final DyttApi api;
  final int categoryId;
  final int movieId;

  DyttMovieDetail? _movie;
  bool _loading = false;
  String? _error;
  bool _disposed = false;

  /// 加载完成前是列表项（字段可能不全），成功后替换为完整详情。
  DyttMovieDetail? get movie => _movie;

  bool get isLoading => _loading;

  String? get error => _error;

  Future<void> load() async {
    if (_loading || _disposed) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      final detail = await api.movieDetail(
        categoryId: categoryId,
        movieDetailId: movieId,
      );
      if (_disposed) return;
      _movie = detail;
    } catch (error) {
      if (!_disposed) _error = dyttErrorMessage(error);
    } finally {
      if (!_disposed) {
        _loading = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
