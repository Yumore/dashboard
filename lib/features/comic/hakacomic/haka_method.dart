/// HTTP methods understood by the signature algorithm.
///
/// `value` is the upper-case verb mixed into the signature key
/// (`haka_comic/lib/network/utils.dart:58-67`).
enum HakaMethod {
  get('GET'),
  post('POST'),
  delete('DELETE'),
  put('PUT');

  const HakaMethod(this.value);

  final String value;
}
