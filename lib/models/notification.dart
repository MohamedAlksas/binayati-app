class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedEntityId;
  final String relatedEntityType;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityId,
    required this.relatedEntityType,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      relatedEntityId: json['relatedEntityId'],
      relatedEntityType: json['relatedEntityType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
