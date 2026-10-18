/// Lifecycle of a single request: nothing / in-flight / value / error.
///
/// Ported from the sealed hierarchy in
/// `haka_comic/lib/utils/request/request_state.dart`.
abstract class HakaRequestState<T> {
  const HakaRequestState();

  bool get isLoading => false;

  bool get hasData => false;

  bool get hasError => false;

  /// Value when in the success state, else `null`.
  T? get data => null;

  /// Error object when in the failure state, else `null`.
  Object? get error => null;
}
