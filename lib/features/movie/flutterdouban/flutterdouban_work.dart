import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// One row of `/v2/movie/celebrity/{id}/works`: `{roles, subject}`.
class FlutterDouBanWork {
  const FlutterDouBanWork({this.roles = const <String>[], this.subject});

  factory FlutterDouBanWork.fromJson(Map<String, dynamic> json) {
    final subject = FlutterDouBanJson.asMapOrNull(json['subject']);
    return FlutterDouBanWork(
      roles: FlutterDouBanJson.asStringList(json['roles']),
      subject: subject == null ? null : FlutterDouBanSubject.fromJson(subject),
    );
  }

  static List<FlutterDouBanWork> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanWork.fromJson).toList(growable: false);

  final List<String> roles;
  final FlutterDouBanSubject? subject;

  String get rolesText => roles.where((role) => role.isNotEmpty).join(' / ');
}
