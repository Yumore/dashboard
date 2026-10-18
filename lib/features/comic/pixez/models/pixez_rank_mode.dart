/// The 12 ranking modes offered by the source `RankPage` (order preserved —
/// the UI and the pixiv API both depend on the exact mode codes).
class PixezRankMode {
  const PixezRankMode({required this.code, required this.label});

  final String code;
  final String label;

  static const List<PixezRankMode> all = <PixezRankMode>[
    PixezRankMode(code: 'day', label: '日榜'),
    PixezRankMode(code: 'day_male', label: '男性向'),
    PixezRankMode(code: 'day_female', label: '女性向'),
    PixezRankMode(code: 'week_original', label: '原创周榜'),
    PixezRankMode(code: 'week_rookie', label: '新人周榜'),
    PixezRankMode(code: 'week', label: '周榜'),
    PixezRankMode(code: 'month', label: '月榜'),
    PixezRankMode(code: 'day_ai', label: 'AI 日榜'),
    PixezRankMode(code: 'day_r18_ai', label: 'R18 AI 日榜'),
    PixezRankMode(code: 'day_r18', label: 'R18 日榜'),
    PixezRankMode(code: 'week_r18', label: 'R18 周榜'),
    PixezRankMode(code: 'week_r18g', label: 'R18G 周榜'),
  ];

  static String labelOf(String code) {
    for (final mode in all) {
      if (mode.code == code) return mode.label;
    }
    return code;
  }
}
