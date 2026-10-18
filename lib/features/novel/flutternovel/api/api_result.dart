/// The host port of the source's `BaseResponse<T>` (api_novel.dart).
///
/// The source defaulted both fields to null and let callers flip `isSuccess`;
/// the port keeps the same shape but exposes [ApiResult.success] /
/// [ApiResult.failure] so the "printed the error and returned a failure"
/// behaviour of every source API call is explicit.
class ApiResult<T> {
  ApiResult({this.isSuccess = false, this.data});

  ApiResult.success(this.data) : isSuccess = true;

  ApiResult.failure() : isSuccess = false, data = null;

  bool isSuccess;
  T? data;

  bool get hasData => isSuccess && data != null;

  @override
  String toString() => 'ApiResult(isSuccess: $isSuccess, data: $data)';
}
