/// 源工程 `lib/src/common/data/failures/http_failure.dart`。
///
/// 书库请求失败时只区分 404 与其它；`description` 被 riverpod notifier 抛成
/// 异常文案，页面再把它显示在重试按钮上方。
enum FeedbooksHttpFailure {
  notFound('404 not found'),
  unknown('Unknown error');

  const FeedbooksHttpFailure(this.description);

  final String description;
}
