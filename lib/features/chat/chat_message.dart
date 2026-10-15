class ChatMessage {
  const ChatMessage({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    this.type = 0,
  });

  final String idFrom;
  final String idTo;
  final DateTime timestamp;
  final String content;
  final int type;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    idFrom: '${json['idFrom'] ?? ''}',
    idTo: '${json['idTo'] ?? ''}',
    timestamp:
        DateTime.tryParse('${json['timestamp'] ?? ''}') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    content: '${json['content'] ?? ''}',
    type: int.tryParse('${json['type'] ?? 0}') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'idFrom': idFrom,
    'idTo': idTo,
    'timestamp': timestamp.toIso8601String(),
    'content': content,
    'type': type,
  };
}
