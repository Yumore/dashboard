class ChatConversation {
  const ChatConversation({required this.id, required this.name});

  final String id;
  final String name;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
