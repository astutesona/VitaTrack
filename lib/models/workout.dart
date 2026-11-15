class Workout {
  final String workoutId;
  final String userId;
  final String workoutType; // Walking, Running, Cycling, Yoga, Strength Training, Other Activities
  final int duration; // in minutes
  final DateTime workoutDate;
  final int caloriesBurned;
  final String notes;

  Workout({
    required this.workoutId,
    required this.userId,
    required this.workoutType,
    required this.duration,
    required this.workoutDate,
    required this.caloriesBurned,
    this.notes = '',
  });

  // MET-based approximate calorie calculation if not manually provided
  static int estimateCalories(String type, int durationMinutes, double weightKg) {
    double met = 4.0;
    switch (type.toLowerCase()) {
      case 'running':
        met = 8.5;
        break;
      case 'cycling':
        met = 6.8;
        break;
      case 'strength training':
        met = 5.0;
        break;
      case 'yoga':
        met = 3.0;
        break;
      case 'walking':
        met = 3.5;
        break;
      default:
        met = 4.5;
        break;
    }
    // Calories = MET * weight(kg) * time(hours)
    final double hours = durationMinutes / 60.0;
    return (met * weightKg * hours).round();
  }

  Workout copyWith({
    String? workoutId,
    String? userId,
    String? workoutType,
    int? duration,
    DateTime? workoutDate,
    int? caloriesBurned,
    String? notes,
  }) {
    return Workout(
      workoutId: workoutId ?? this.workoutId,
      userId: userId ?? this.userId,
      workoutType: workoutType ?? this.workoutType,
      duration: duration ?? this.duration,
      workoutDate: workoutDate ?? this.workoutDate,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'userId': userId,
      'workoutType': workoutType,
      'duration': duration,
      'workoutDate': workoutDate.toIso8601String(),
      'caloriesBurned': caloriesBurned,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, {String? id}) {
    return Workout(
      workoutId: id ?? map['workoutId'] ?? '',
      userId: map['userId'] ?? '',
      workoutType: map['workoutType'] ?? 'Walking',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      workoutDate: map['workoutDate'] != null
          ? DateTime.tryParse(map['workoutDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      notes: map['notes'] ?? '',
    );
  }
}
