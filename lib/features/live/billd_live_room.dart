class BilldLiveRoom {
  const BilldLiveRoom({
    required this.id,
    required this.title,
    this.cover,
    this.description = '',
  });

  final String id;
  final String title;
  final Uri? cover;
  final String description;

  factory BilldLiveRoom.fromJson(Map<String, dynamic> json) {
    final coverValue =
        '${json['cover'] ?? json['coverUrl'] ?? json['img'] ?? ''}';
    return BilldLiveRoom(
      id: '${json['id'] ?? json['roomId'] ?? json['liveRoomId'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? json['roomName'] ?? '未命名直播间'}',
      cover: coverValue.isEmpty ? null : Uri.tryParse(coverValue),
      description: '${json['desc'] ?? json['description'] ?? ''}',
    );
  }
}
