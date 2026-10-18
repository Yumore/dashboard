import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// The dmzj v3 `recommend.json` novel card.
///
/// The source declared the dmzj endpoint (`RequestApi.HOME_RECOMMEND`) but never
/// modelled or called it, so this mapper is hand-written against the dmzj v3
/// novel keys that the host's own dmzj module already consumes
/// (lib/models/novel/novel_detail_model.dart): id, name, cover, authors, status,
/// last_update_chapter_name, last_update_chapter_id, last_update_volume_id,
/// last_update_time, hot_hits, introduction, types, first_letter, zone,
/// subscribe_num.
class DmzjNovelBrief {
  DmzjNovelBrief({
    this.id,
    this.name,
    this.cover,
    this.authors,
    this.status,
    this.lastUpdateChapterName,
    this.lastUpdateChapterId,
    this.lastUpdateVolumeId,
    this.lastUpdateTime,
    this.hotHits,
    this.introduction,
    this.types = const <String>[],
    this.firstLetter,
    this.zone,
    this.subscribeNum,
  });

  String? id;
  String? name;
  String? cover;
  String? authors;
  String? status;
  String? lastUpdateChapterName;
  int? lastUpdateChapterId;
  int? lastUpdateVolumeId;
  int? lastUpdateTime;
  int? hotHits;
  String? introduction;
  List<String> types;
  String? firstLetter;
  String? zone;
  int? subscribeNum;

  factory DmzjNovelBrief.fromJson(Map<String, dynamic> json) => DmzjNovelBrief(
    id: readString(json, 'id'),
    name: readString(json, 'name'),
    cover: readString(json, 'cover'),
    authors: readString(json, 'authors'),
    status: readString(json, 'status'),
    lastUpdateChapterName: readString(json, 'last_update_chapter_name'),
    lastUpdateChapterId: readInt(json, 'last_update_chapter_id'),
    lastUpdateVolumeId: readInt(json, 'last_update_volume_id'),
    lastUpdateTime: readInt(json, 'last_update_time'),
    hotHits: readInt(json, 'hot_hits'),
    introduction: readString(json, 'introduction'),
    types: readStringList(json, 'types'),
    firstLetter: readString(json, 'first_letter'),
    zone: readString(json, 'zone'),
    subscribeNum: readInt(json, 'subscribe_num'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'cover': cover,
    'authors': authors,
    'status': status,
    'last_update_chapter_name': lastUpdateChapterName,
    'last_update_chapter_id': lastUpdateChapterId,
    'last_update_volume_id': lastUpdateVolumeId,
    'last_update_time': lastUpdateTime,
    'hot_hits': hotHits,
    'introduction': introduction,
    'types': types,
    'first_letter': firstLetter,
    'zone': zone,
    'subscribe_num': subscribeNum,
  };
}
