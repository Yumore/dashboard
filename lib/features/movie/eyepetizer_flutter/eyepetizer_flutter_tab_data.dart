import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/person_mainpage.dart` → `TabData`.
///
/// `apiUrl` is what a person-home tab passes to
/// `EyepetizerFlutterPersonRepository.getPersonHomePageData` (it arrives as a
/// full absolute URL).
class EyepetizerFlutterTabData {
  const EyepetizerFlutterTabData({
    this.id,
    this.name,
    this.apiUrl,
    this.tabType,
    this.nameType,
  });

  factory EyepetizerFlutterTabData.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterTabData(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        name: EyepetizerFlutterJson.asNullableString(json['name']),
        apiUrl: EyepetizerFlutterJson.asNullableString(json['apiUrl']),
        tabType: EyepetizerFlutterJson.asNullableInt(json['tabType']),
        nameType: EyepetizerFlutterJson.asNullableInt(json['nameType']),
      );

  final int? id;
  final String? name;
  final String? apiUrl;
  final int? tabType;
  final int? nameType;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'apiUrl': apiUrl,
    'tabType': tabType,
    'nameType': nameType,
  };
}
