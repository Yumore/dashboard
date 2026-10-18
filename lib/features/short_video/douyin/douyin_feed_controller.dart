import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_error_message.dart';

/// 榜单页控制器：只负责拉 `billboard_data`。
class DouyinFeedController {
  DouyinFeedController({required this.api, this.billboardType = 4});

  final DouyinApi api;
  final int billboardType;

  List<DouyinBillboardEntry> entries = const <DouyinBillboardEntry>[];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    try {
      final response = await api.fetchBillboard(billboardType: billboardType);
      entries = response.entries;
    } catch (failure) {
      error = douyinErrorMessage(failure);
      entries = const <DouyinBillboardEntry>[];
    } finally {
      isLoading = false;
    }
  }
}
