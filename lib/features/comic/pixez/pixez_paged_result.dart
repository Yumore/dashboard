import 'pixez_json.dart';

/// A `{itemsKey: [...], next_url: "..."}` response, the shape used by
/// recommended/ranking/search/related/user-illust endpoints.
class PixezPagedResult<T> {
  const PixezPagedResult({required this.items, this.nextUrl});

  final List<T> items;
  final String? nextUrl;

  bool get hasMore => nextUrl != null && nextUrl!.trim().isNotEmpty;

  factory PixezPagedResult.fromJson(
    Map<String, dynamic> json, {
    required String itemsKey,
    required T Function(Map<String, dynamic>) itemParser,
  }) {
    final items = <T>[
      for (final item in pixezMapList(json[itemsKey])) itemParser(item),
    ];
    return PixezPagedResult<T>(
      items: items,
      nextUrl: pixezStringOrNull(json['next_url']),
    );
  }
}
