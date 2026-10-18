/// 登录态。
///
/// 源工程 `Api.dioClient` 的 `onRequest` 拦截器在已登录时给**每个**请求加上
/// `uid` / `token`：
///
/// ```dart
/// if (MyApp.rrUser.uid != null) {
///   options.queryParameters.addAll({"uid": ..., "token": ...});
/// }
/// ```
///
/// 移植版不搬 `MyApp` 全局单例（宿主没有它），改成一个可注入的小对象：
/// 默认是匿名（不追加参数），需要登录态的调用方自己塞一个实例即可。
class YyetsSession {
  const YyetsSession({this.uid, this.token});

  /// 匿名会话：源工程里 `MyApp.rrUser.uid == null` 的情形。
  static const YyetsSession anonymous = YyetsSession();

  final String? uid;
  final String? token;

  bool get isLoggedIn =>
      uid != null && uid!.isNotEmpty && token != null && token!.isNotEmpty;

  /// 源工程拦截器追加的查询参数。
  Map<String, String> get authQuery => isLoggedIn
      ? <String, String>{'uid': uid!, 'token': token!}
      : const <String, String>{};

  factory YyetsSession.fromUserJson(Map<String, dynamic> json) => YyetsSession(
    uid: json['uid']?.toString(),
    token: json['token']?.toString(),
  );
}
