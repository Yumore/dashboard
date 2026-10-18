/// `lib/utils/string_util.dart` of the source app, unchanged in behaviour.
///
/// The empty-`String` case is what decides whether a login/register field, a
/// `nextPageUrl` or a `baseUrl` override is treated as "not supplied".
class EyepetizerFlutterStringUtil {
  const EyepetizerFlutterStringUtil._();

  static bool isEmpty(Object? object) {
    if (object == null) return true;
    if (object is String && object.isEmpty) {
      return true;
    } else if (object is Iterable && object.isEmpty) {
      return true;
    } else if (object is Map && object.isEmpty) {
      return true;
    }
    return false;
  }
}
