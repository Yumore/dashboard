import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';

/// Query of `GET comics` (`haka_comic/lib/network/models.dart:168-203`).
///
/// Only non-null fields are serialized, and `s` is sent as the enum *name*.
class HakaComicsPayload {
  const HakaComicsPayload({
    this.page,
    this.c,
    this.s,
    this.t,
    this.a,
    this.ct,
    this.ca,
  });

  final int? page;

  /// Category id.
  final String? c;

  final HakaComicSortType? s;

  /// Tag.
  final String? t;

  /// Author.
  final String? a;

  /// Translation team.
  final String? ct;

  /// Uploader.
  final String? ca;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (page != null) json['page'] = page;
    if (c != null) json['c'] = c;
    if (s != null) json['s'] = s!.name;
    if (a != null) json['a'] = a;
    if (ca != null) json['ca'] = ca;
    if (ct != null) json['ct'] = ct;
    if (t != null) json['t'] = t;
    return json;
  }
}
