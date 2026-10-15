class LanChatRoster {
  const LanChatRoster({
    required this.user,
    required this.sessionId,
    required this.peers,
  });

  final String user;
  final String sessionId;
  final List<String> peers;

  factory LanChatRoster.fromJson(Map<String, dynamic> json) {
    final users = json['userList'];
    if (users is! List) throw const FormatException('用户列表格式错误');
    final user = '${json['currentUserName'] ?? ''}';
    if (user.isEmpty) throw const FormatException('服务端没有返回当前用户');
    return LanChatRoster(
      user: user,
      sessionId: '${json['currentUserId'] ?? '0'}',
      peers: users
          .whereType<String>()
          .where((peer) => peer != user)
          .toSet()
          .toList(),
    );
  }
}
