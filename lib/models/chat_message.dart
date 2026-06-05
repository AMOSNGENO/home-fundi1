class ChatThread {
  final String id;
  final String title;
  final String subtitle;
  final String? requestId;
  final String recipientId;
  final String recipientRole;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;

  const ChatThread({
    required this.id,
    required this.title,
    required this.subtitle,
    this.requestId,
    required this.recipientId,
    required this.recipientRole,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? 'Chat'}',
      subtitle: '${json['subtitle'] ?? ''}',
      requestId: (json['request_id'] ?? json['requestId'])?.toString(),
      recipientId: '${json['recipient_id'] ?? json['recipientId'] ?? ''}',
      recipientRole: '${json['recipient_role'] ?? json['recipientRole'] ?? ''}',
      lastMessage: '${json['last_message'] ?? json['lastMessage'] ?? ''}',
      lastMessageAt: '${json['last_message_at'] ?? json['lastMessageAt'] ?? ''}',
      unreadCount: int.tryParse('${json['unread_count'] ?? 0}') ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final bool isMine;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.isMine,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: '${json['id'] ?? ''}',
      senderId: '${json['sender_id'] ?? json['senderId'] ?? ''}',
      senderName: '${json['sender_name'] ?? json['senderName'] ?? 'User'}',
      message: '${json['message'] ?? ''}',
      isMine: json['is_mine'] == true ||
          json['is_mine'] == 1 ||
          json['is_mine'] == '1' ||
          json['isMine'] == true,
      createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
    );
  }
}
