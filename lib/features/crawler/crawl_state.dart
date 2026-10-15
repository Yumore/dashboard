enum CrawlState {
  idle('未开始'),
  running('运行中'),
  paused('已暂停'),
  stopped('已停止'),
  completed('已完成'),
  failed('失败');

  const CrawlState(this.label);
  final String label;
}
