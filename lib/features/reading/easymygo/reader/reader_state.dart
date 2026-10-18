import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// Reader lifecycle, mirroring the loading/error/ready states EasyMyGo's reader
/// controllers exposed (`HomeViewState`-style freezed states in the source app).
enum ReaderStatus { idle, loading, ready, error }

/// Immutable reader snapshot.
///
/// Manga chapters produce [pictures]; novel chapters produce [pages] (the text
/// split by the paginator). [pageIndex] is the cursor for whichever list is
/// active.
class ReaderState {
  const ReaderState({
    required this.type,
    this.status = ReaderStatus.idle,
    this.volumeIndex = 0,
    this.volumeId = '',
    this.volumeLabel = '',
    this.chapterIndex = 0,
    this.chapterId = '',
    this.chapterLabel = '',
    this.pictures = const <MangaPicture>[],
    this.pages = const <String>[],
    this.pageIndex = 0,
    this.errorMsg = '',
    this.payload,
  });

  final SourceType type;
  final ReaderStatus status;
  final int volumeIndex;
  final String volumeId;
  final String volumeLabel;
  final int chapterIndex;
  final String chapterId;
  final String chapterLabel;
  final List<MangaPicture> pictures;
  final List<String> pages;
  final int pageIndex;
  final String errorMsg;
  final ComponentPayload? payload;

  bool get isManga => type == SourceType.manga;

  int get pageCount => isManga ? pictures.length : pages.length;

  double get process =>
      pageCount <= 0 ? 0 : ((pageIndex + 1) / pageCount).clamp(0.0, 1.0);

  ReaderState copyWith({
    SourceType? type,
    ReaderStatus? status,
    int? volumeIndex,
    String? volumeId,
    String? volumeLabel,
    int? chapterIndex,
    String? chapterId,
    String? chapterLabel,
    List<MangaPicture>? pictures,
    List<String>? pages,
    int? pageIndex,
    String? errorMsg,
    ComponentPayload? payload,
  }) => ReaderState(
    type: type ?? this.type,
    status: status ?? this.status,
    volumeIndex: volumeIndex ?? this.volumeIndex,
    volumeId: volumeId ?? this.volumeId,
    volumeLabel: volumeLabel ?? this.volumeLabel,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    chapterId: chapterId ?? this.chapterId,
    chapterLabel: chapterLabel ?? this.chapterLabel,
    pictures: pictures ?? this.pictures,
    pages: pages ?? this.pages,
    pageIndex: pageIndex ?? this.pageIndex,
    errorMsg: errorMsg ?? this.errorMsg,
    payload: payload ?? this.payload,
  );
}
