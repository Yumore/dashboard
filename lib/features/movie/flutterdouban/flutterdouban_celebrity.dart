import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_images.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_photo.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_work.dart';

/// `/v2/movie/celebrity/{id}` — the source's `CelebrityEntity`.
///
/// Real fields: `name_en`, `born_place`, `aka_en`, `professions`, `avatars`,
/// `photos`, `works`, `summary`, `mobile_url`.
class FlutterDouBanCelebrity {
  const FlutterDouBanCelebrity({
    this.id = '',
    this.name = '',
    this.nameEn = '',
    this.gender = '',
    this.alt = '',
    this.avatars = const FlutterDouBanImages(),
    this.birthday = '',
    this.bornPlace = '',
    this.constellation = '',
    this.aka = const <String>[],
    this.akaEn = const <String>[],
    this.professions = const <String>[],
    this.summary = '',
    this.website = '',
    this.mobileUrl = '',
    this.photos = const <FlutterDouBanPhoto>[],
    this.works = const <FlutterDouBanWork>[],
  });

  factory FlutterDouBanCelebrity.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanCelebrity(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        name: FlutterDouBanJson.asString(json['name']).trim(),
        nameEn: FlutterDouBanJson.asString(json['name_en']).trim(),
        gender: FlutterDouBanJson.asString(json['gender']).trim(),
        alt: FlutterDouBanJson.asString(json['alt']).trim(),
        avatars: FlutterDouBanImages.fromJson(
          FlutterDouBanJson.asMapOrNull(json['avatars']),
        ),
        birthday: FlutterDouBanJson.asString(json['birthday']).trim(),
        bornPlace: FlutterDouBanJson.asString(json['born_place']).trim(),
        constellation: FlutterDouBanJson.asString(json['constellation']).trim(),
        aka: FlutterDouBanJson.asStringList(json['aka']),
        akaEn: FlutterDouBanJson.asStringList(json['aka_en']),
        professions: FlutterDouBanJson.asStringList(json['professions']),
        summary: FlutterDouBanJson.asString(json['summary']).trim(),
        website: FlutterDouBanJson.asString(json['website']).trim(),
        mobileUrl: FlutterDouBanJson.asString(json['mobile_url']).trim(),
        photos: FlutterDouBanPhoto.listFrom(json['photos']),
        works: FlutterDouBanWork.listFrom(json['works']),
      );

  final String id;
  final String name;
  final String nameEn;
  final String gender;
  final String alt;
  final FlutterDouBanImages avatars;
  final String birthday;
  final String bornPlace;
  final String constellation;
  final List<String> aka;
  final List<String> akaEn;
  final List<String> professions;
  final String summary;
  final String website;
  final String mobileUrl;
  final List<FlutterDouBanPhoto> photos;
  final List<FlutterDouBanWork> works;

  String? get avatarUrl => FlutterDouBanImage.resolve(avatars.preferred);

  bool get hasSummary => summary.isNotEmpty;

  /// Douban pads `professions` with empty strings (the ported
  /// `mock/celebrity.json` has `['', '', '导演', '制片人', '编剧']`).
  List<String> get realProfessions =>
      professions.where((item) => item.isNotEmpty).toList();

  String get professionsText => realProfessions.join(' / ');

  List<String> get akaAll => <String>[
    ...aka.where((item) => item.isNotEmpty),
    ...akaEn.where((item) => item.isNotEmpty),
  ];

  /// The detail page shows a profile line for whichever of these exist.
  String get profileLine {
    final parts = <String>[
      if (gender.isNotEmpty) gender,
      if (birthday.isNotEmpty) birthday,
      if (bornPlace.isNotEmpty) bornPlace,
      if (constellation.isNotEmpty) constellation,
    ];
    return parts.join(' · ');
  }
}
