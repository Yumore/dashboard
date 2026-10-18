import 'package:dashboard/features/comic/hakacomic/haka_chapters.dart';

/// `GET comics/{id}/eps` payload (`haka_comic/lib/network/models.dart:491-501`).
class HakaChaptersResponse {
  const HakaChaptersResponse({required this.eps});

  final HakaChapters eps;

  factory HakaChaptersResponse.fromJson(Map<String, dynamic> json) {
    return HakaChaptersResponse(
      eps: HakaChapters.fromJson(json['eps'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'eps': eps.toJson()};
}
