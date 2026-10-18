import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';

/// Completed request (`haka_comic/lib/utils/request/request_state.dart:29-35`).
class HakaSuccess<T> extends HakaRequestState<T> {
  const HakaSuccess(this.data);

  @override
  final T data;

  @override
  bool get hasData => true;
}
