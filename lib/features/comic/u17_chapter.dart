class U17Chapter {
  const U17Chapter({required this.id, required this.name, this.locked = false});

  final int id;
  final String name;
  final bool locked;

  factory U17Chapter.fromJson(Map<String, dynamic> json) => U17Chapter(
    id: int.tryParse('${json['chapter_id'] ?? 0}') ?? 0,
    name: '${json['name'] ?? ''}',
    locked:
        json['has_locked_image'] == true ||
        '${json['has_locked_image']}' == '1',
  );

  Map<String, Object?> toJson() => {
    'chapter_id': id,
    'name': name,
    'has_locked_image': locked,
  };
}
