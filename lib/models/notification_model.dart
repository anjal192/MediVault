class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // "medicineReminder", "lowStock", "doctorAppointment", "general"
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      isRead: map['isRead'] ?? false,
    );
  }
}
