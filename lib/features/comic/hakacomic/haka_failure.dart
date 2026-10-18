import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';

/// Failed request (`haka_comic/lib/utils/request/request_state.dart:37-43`).
class HakaFailure<T> extends HakaRequestState<T> {
  const HakaFailure(this.error);

  @override
  final Object error;

  @override
  bool get hasError => true;
}
