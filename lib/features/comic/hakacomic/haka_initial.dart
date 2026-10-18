import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';

/// No request has been issued yet
/// (`haka_comic/lib/utils/request/request_state.dart:10-16`).
class HakaInitial<T> extends HakaRequestState<T> {
  const HakaInitial();
}
