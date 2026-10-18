/// A tiny load-state holder for the ported screens, mirroring the douban port's
/// `FlutterDouBanLoadState`.
///
/// The source used a shared `BaseChangeNotifierModel` with `error` / `isLoading`
/// flags and called `setState` from the view models. The port keeps the same
/// three facts and lets each `State` own them.
class EyepetizerLoadState<T> {
  EyepetizerLoadState({this.data, this.error, this.loading = false});

  T? data;
  String? error;
  bool loading;

  bool get hasData => data != null;

  bool get hasError => error != null;

  void reset() {
    data = null;
    error = null;
    loading = false;
  }
}
