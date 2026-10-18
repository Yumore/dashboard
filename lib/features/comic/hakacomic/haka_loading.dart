import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';

/// In-flight request, optionally carrying the previous value so a refresh can
/// keep rendering it (`haka_comic/lib/utils/request/request_state.dart:18-27`).
class HakaLoading<T> extends HakaRequestState<T> {
  const HakaLoading([this.previous]);

  final T? previous;

  @override
  bool get isLoading => true;

  @override
  T? get data => previous;
}
