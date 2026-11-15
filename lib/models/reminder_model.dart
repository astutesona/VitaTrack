class ReminderModel {
  final String reminderId;
  final String userId;
  final String reminderType; // 'Water', 'Walking', 'Sleep'
  final String reminderTime; // '08:30', '14:00', etc.
  final bool isEnabled;
  final String title;
  final String message;
  final int notificationId;

  ReminderModel({
    required this.reminderId,
    required this.userId,
    required this.reminderType,
    required this.reminderTime,
    required this.isEnabled,
    required this.title,
    required this.message,
    required this.notificationId,
  });

  ReminderModel copyWith({
    String? reminderId,
    String? userId,
    String? reminderType,
    String? reminderTime,
    bool? isEnabled,
    String? title,
    String? message,
    int? notificationId,
  }) {
    return ReminderModel(
      reminderId: reminderId ?? this.reminderId,
      userId: userId ?? this.userId,
      reminderType: reminderType ?? this.reminderType,
      reminderTime: reminderTime ?? this.reminderTime,
      isEnabled: isEnabled ?? this.isEnabled,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'userId': userId,
      'reminderType': reminderType,
      'reminderTime': reminderTime,
      'isEnabled': isEnabled,
      'title': title,
      'message': message,
      'notificationId': notificationId,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReminderModel(
      reminderId: id ?? map['reminderId'] ?? '',
      userId: map['userId'] ?? '',
      reminderType: map['reminderType'] ?? 'Water',
      reminderTime: map['reminderTime'] ?? '09:00',
      isEnabled: map['isEnabled'] ?? true,
      title: map['title'] ?? 'VitaTrack Reminder',
      message: map['message'] ?? 'Time to stay healthy!',
      notificationId: (map['notificationId'] as num?)?.toInt() ?? 101,
    );
  }
}
