import 'package:dashboard/features/comic/picacomic/core/history_type.dart';

/// Ports PicaComic's `HistoryMixin`: anything that can be remembered as a
/// local reading-history entry.
mixin HistoryMixin {
  String get title;

  String? get subTitle;

  String get cover;

  /// Identifier used as the history primary key.
  String get target;

  /// Highest page number, when the model knows it.
  int? get maxPage => null;

  HistoryType get historyType;
}
