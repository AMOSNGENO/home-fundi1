class AppNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? 'Notification'}',
      message: '${json['message'] ?? ''}',
      isRead:
          json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1' ||
          json['isRead'] == true,
      createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
    );
  }
}
