import '../pixez_json.dart';

/// The `profile_publicity` object of `/v1/user/detail`.
///
/// The source model keeps `birth_year` as a string here (the endpoint returns
/// a string, unlike `profile.birth_year`).
class PixezUserPublicity {
  const PixezUserPublicity({
    this.gender,
    this.region,
    this.birthDay,
    this.birthYear,
    this.job,
    this.pawoo = false,
  });

  final String? gender;
  final String? region;
  final String? birthDay;
  final String? birthYear;
  final String? job;
  final bool pawoo;

  factory PixezUserPublicity.fromJson(Map<String, dynamic> json) {
    return PixezUserPublicity(
      gender: pixezStringOrNull(json['gender']),
      region: pixezStringOrNull(json['region']),
      birthDay: pixezStringOrNull(json['birth_day']),
      birthYear: pixezStringOrNull(json['birth_year']),
      job: pixezStringOrNull(json['job']),
      pawoo: pixezBool(json['pawoo']),
    );
  }
}
