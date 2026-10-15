import 'dart:convert';

class LanChatMessage {
  const LanChatMessage({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.text,
    this.sessionId = '0',
    this.messageType = 1,
    this.type = 2,
  });

  final String id;
  final String sender;
  final String recipient;
  final String text;
  final String sessionId;
  final int messageType;
  final int type;

  factory LanChatMessage.fromJson(Map<String, dynamic> json) => LanChatMessage(
    id: '${json['msgId'] ?? ''}',
    sender: '${json['fromUserName'] ?? ''}',
    recipient: '${json['to'] ?? ''}',
    text: '${json['msg'] ?? ''}',
    sessionId: '${json['fromSessionId'] ?? '0'}',
    messageType: int.tryParse('${json['msgType'] ?? 1}') ?? 1,
    type: int.tryParse('${json['type'] ?? 2}') ?? 2,
  );

  Map<String, dynamic> toJson() => {
    'msgId': id,
    'fromUserName': sender,
    'fromSessionId': sessionId,
    'to': recipient,
    'msg': text,
    'msgType': messageType,
    'type': type,
  };

  String encode() => jsonEncode(toJson());
}
