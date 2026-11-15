class UserProfile {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;
  final int stepGoal;
  final int waterGoalMl;
  final double sleepGoalHours;
  final int workoutGoalMinutes;
  final double heightCm;
  final double weightKg;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    this.stepGoal = 8000,
    this.waterGoalMl = 2500,
    this.sleepGoalHours = 8.0,
    this.workoutGoalMinutes = 150,
    this.heightCm = 170.0,
    this.weightKg = 68.0,
  });

  // Calculate Body Mass Index
  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final double heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  String get bmiCategory {
    final double value = bmi;
    if (value < 18.5) return 'Underweight';
    if (value < 25.0) return 'Normal weight';
    if (value < 30.0) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    DateTime? createdAt,
    int? stepGoal,
    int? waterGoalMl,
    double? sleepGoalHours,
    int? workoutGoalMinutes,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      stepGoal: stepGoal ?? this.stepGoal,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      sleepGoalHours: sleepGoalHours ?? this.sleepGoalHours,
      workoutGoalMinutes: workoutGoalMinutes ?? this.workoutGoalMinutes,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'stepGoal': stepGoal,
      'waterGoalMl': waterGoalMl,
      'sleepGoalHours': sleepGoalHours,
      'workoutGoalMinutes': workoutGoalMinutes,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      userId: id ?? map['userId'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      stepGoal: (map['stepGoal'] as num?)?.toInt() ?? 8000,
      waterGoalMl: (map['waterGoalMl'] as num?)?.toInt() ?? 2500,
      sleepGoalHours: (map['sleepGoalHours'] as num?)?.toDouble() ?? 8.0,
      workoutGoalMinutes: (map['workoutGoalMinutes'] as num?)?.toInt() ?? 150,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 68.0,
    );
  }
}
