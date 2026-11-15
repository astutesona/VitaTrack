class WaterLogItem {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  WaterLogItem({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterLogItem.fromMap(Map<String, dynamic> map) {
    return WaterLogItem(
      id: map['id'] ?? '',
      amountMl: (map['amountMl'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class HealthRecord {
  final String id;
  final String userId;
  final String date; // Format: YYYY-MM-DD
  final int steps;
  final int waterIntake; // in ml
  final double sleepDuration; // in hours, e.g. 7.5
  final String? sleepStartTime;
  final String? sleepEndTime;
  final String? sleepQuality; // 'Deep', 'Light', 'Restless'
  final List<WaterLogItem> waterLogs;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.date,
    this.steps = 0,
    this.waterIntake = 0,
    this.sleepDuration = 0.0,
    this.sleepStartTime,
    this.sleepEndTime,
    this.sleepQuality,
    List<WaterLogItem>? waterLogs,
    DateTime? updatedAt,
  })  : waterLogs = waterLogs ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  HealthRecord copyWith({
    String? id,
    String? userId,
    String? date,
    int? steps,
    int? waterIntake,
    double? sleepDuration,
    String? sleepStartTime,
    String? sleepEndTime,
    String? sleepQuality,
    List<WaterLogItem>? waterLogs,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      waterLogs: waterLogs ?? this.waterLogs,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'steps': steps,
      'waterIntake': waterIntake,
      'sleepDuration': sleepDuration,
      'sleepStartTime': sleepStartTime,
      'sleepEndTime': sleepEndTime,
      'sleepQuality': sleepQuality,
      'waterLogs': waterLogs.map((item) => item.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawLogs = map['waterLogs'] as List<dynamic>?;
    List<WaterLogItem> logs = [];
    if (rawLogs != null) {
      logs = rawLogs
          .map((item) => WaterLogItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return HealthRecord(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      waterIntake: (map['waterIntake'] as num?)?.toInt() ?? 0,
      sleepDuration: (map['sleepDuration'] as num?)?.toDouble() ?? 0.0,
      sleepStartTime: map['sleepStartTime'],
      sleepEndTime: map['sleepEndTime'],
      sleepQuality: map['sleepQuality'],
      waterLogs: logs,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
