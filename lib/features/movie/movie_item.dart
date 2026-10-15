class MovieItem {
  const MovieItem({
    required this.id,
    required this.title,
    this.poster,
    this.description = '',
    this.source,
    this.category = '',
    this.serviceEndpoint,
  });

  final int id;
  final String title;
  final Uri? poster;
  final String description;
  final Uri? source;
  final String category;
  final Uri? serviceEndpoint;

  factory MovieItem.fromJson(Map<String, dynamic> json, Uri endpoint) {
    Uri? resolve(Object? raw) {
      final value = raw?.toString() ?? '';
      return value.isEmpty
          ? null
          : endpoint.resolve(value.replaceAll('{size}', '480'));
    }

    return MovieItem(
      id: int.tryParse('${json['id'] ?? json['movieId'] ?? 0}') ?? 0,
      title: '${json['movieName'] ?? json['name'] ?? ''}',
      poster: resolve(json['img'] ?? json['localImg']),
      description: '${json['description'] ?? json['plot'] ?? ''}',
      source: resolve(json['sourceUrl']),
      category: '${json['classify'] ?? json['category'] ?? ''}',
      serviceEndpoint: endpoint,
    );
  }
}
