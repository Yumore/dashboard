/// bilibili `qn` (quality) codes, as used by `x/player/playurl`.
///
/// The source app always requested [biliDefaultQuality] (`qn: 80`) and never
/// read `accept_quality`; the labels below exist so the UI can offer the
/// qualities the API reported back.
const Map<int, String> biliQualityLabels = <int, String>{
  127: '8K 超高清',
  126: '杜比视界',
  125: 'HDR 真彩',
  120: '4K 超清',
  116: '1080P60 帧',
  112: '1080P+ 高码率',
  80: '1080P 高清',
  74: '720P60 帧',
  64: '720P 高清',
  32: '480P 清晰',
  16: '360P 流畅',
  6: '240P 极速',
};

/// The `qn` the source app hard-coded in both play-url call sites.
const int biliDefaultQuality = 80;

/// Qualities offered when the API returned no `accept_quality` list.
const List<int> biliFallbackQualities = <int>[80, 64, 32, 16];

/// Label for [qn], falling back to a plain `qn` echo for unknown codes.
String biliQualityLabel(int qn) => biliQualityLabels[qn] ?? 'qn$qn';
