import '../pixez_json.dart';

/// The `profile` object of `/v1/user/detail`.
class PixezUserProfile {
  const PixezUserProfile({
    this.webpage,
    this.gender,
    this.birth,
    this.birthDay,
    this.birthYear,
    this.region,
    this.addressId,
    this.countryCode,
    this.job,
    this.jobId,
    this.totalFollowUsers = 0,
    this.totalMyPixivUsers = 0,
    this.totalIllusts = 0,
    this.totalManga = 0,
    this.totalNovels = 0,
    this.totalIllustBookmarksPublic = 0,
    this.totalIllustSeries = 0,
    this.totalNovelSeries = 0,
    this.backgroundImageUrl,
    this.twitterAccount,
    this.twitterUrl,
    this.pawooUrl,
    this.isPremium = false,
    this.isUsingCustomProfileImage = false,
  });

  final String? webpage;
  final String? gender;
  final String? birth;
  final String? birthDay;
  final int? birthYear;
  final String? region;
  final int? addressId;
  final String? countryCode;
  final String? job;
  final int? jobId;
  final int totalFollowUsers;
  final int totalMyPixivUsers;
  final int totalIllusts;
  final int totalManga;
  final int totalNovels;
  final int totalIllustBookmarksPublic;
  final int totalIllustSeries;
  final int totalNovelSeries;
  final String? backgroundImageUrl;
  final String? twitterAccount;
  final String? twitterUrl;
  final String? pawooUrl;
  final bool isPremium;
  final bool isUsingCustomProfileImage;

  factory PixezUserProfile.fromJson(Map<String, dynamic> json) {
    return PixezUserProfile(
      webpage: pixezStringOrNull(json['webpage']),
      gender: pixezStringOrNull(json['gender']),
      birth: pixezStringOrNull(json['birth']),
      birthDay: pixezStringOrNull(json['birth_day']),
      birthYear: pixezIntOrNull(json['birth_year']),
      region: pixezStringOrNull(json['region']),
      addressId: pixezIntOrNull(json['address_id']),
      countryCode: pixezStringOrNull(json['country_code']),
      job: pixezStringOrNull(json['job']),
      jobId: pixezIntOrNull(json['job_id']),
      totalFollowUsers: pixezInt(json['total_follow_users']),
      totalMyPixivUsers: pixezInt(json['total_mypixiv_users']),
      totalIllusts: pixezInt(json['total_illusts']),
      totalManga: pixezInt(json['total_manga']),
      totalNovels: pixezInt(json['total_novels']),
      totalIllustBookmarksPublic: pixezInt(
        json['total_illust_bookmarks_public'],
      ),
      totalIllustSeries: pixezInt(json['total_illust_series']),
      totalNovelSeries: pixezInt(json['total_novel_series']),
      backgroundImageUrl: pixezStringOrNull(json['background_image_url']),
      twitterAccount: pixezStringOrNull(json['twitter_account']),
      twitterUrl: pixezStringOrNull(json['twitter_url']),
      pawooUrl: pixezStringOrNull(json['pawoo_url']),
      isPremium: pixezBool(json['is_premium']),
      isUsingCustomProfileImage: pixezBool(
        json['is_using_custom_profile_image'],
      ),
    );
  }
}
