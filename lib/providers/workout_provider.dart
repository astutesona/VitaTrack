import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../utils/date_formatter.dart';

class WorkoutProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentUserId = '';

  // Total active workout minutes today
  int get totalMinutesToday {
    final todayStr = DateFormatter.toIsoDateOnly(DateTime.now());
    return _workouts
        .where((w) => DateFormatter.toIsoDateOnly(w.workoutDate) == todayStr)
        .fold(0, (sum, w) => sum + w.duration);
  }

  // Calories burned today through workouts
  int get caloriesBurnedToday {
    final todayStr = DateFormatter.toIsoDateOnly(DateTime.now());
    return _workouts
        .where((w) => DateFormatter.toIsoDateOnly(w.workoutDate) == todayStr)
        .fold(0, (sum, w) => sum + w.caloriesBurned);
  }

  // Total workout minutes in the last 7 days
  int get totalMinutesThisWeek {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _workouts
        .where((w) => w.workoutDate.isAfter(sevenDaysAgo))
        .fold(0, (sum, w) => sum + w.duration);
  }

  // Group workouts by activity type for analytics
  Map<String, int> get minutesByType {
    final Map<String, int> map = {
      'Walking': 0,
      'Running': 0,
      'Cycling': 0,
      'Yoga': 0,
      'Strength Training': 0,
      'Other Activities': 0,
    };

    for (final w in _workouts) {
      if (map.containsKey(w.workoutType)) {
        map[w.workoutType] = map[w.workoutType]! + w.duration;
      } else {
        map['Other Activities'] = (map['Other Activities'] ?? 0) + w.duration;
      }
    }
    return map;
  }

  Future<void> loadWorkouts(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    _workouts = await _db.getWorkouts(userId);

    // If empty on first launch, add standard sample workouts so UI looks engaging immediately
    if (_workouts.isEmpty) {
      final now = DateTime.now();
      final sample = [
        Workout(
          workoutId: 'w_init_1',
          userId: userId,
          workoutType: 'Running',
          duration: 30,
          workoutDate: now.subtract(const Duration(hours: 3)),
          caloriesBurned: 240,
          notes: 'Morning brisk jog around the neighborhood park.',
        ),
        Workout(
          workoutId: 'w_init_2',
          userId: userId,
          workoutType: 'Cycling',
          duration: 45,
          workoutDate: now.subtract(const Duration(days: 1, hours: 2)),
          caloriesBurned: 310,
          notes: 'Evening cycling session with sprint intervals.',
        ),
        Workout(
          workoutId: 'w_init_3',
          userId: userId,
          workoutType: 'Yoga',
          duration: 25,
          workoutDate: now.subtract(const Duration(days: 2, hours: 1)),
          caloriesBurned: 95,
          notes: 'Gentle sunrise yoga and deep stretching.',
        ),
      ];

      for (final w in sample) {
        await _db.addWorkout(w);
      }
      _workouts = sample;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWorkout(Workout workout) async {
    _workouts.insert(0, workout);
    notifyListeners();
    await _db.addWorkout(workout);
  }

  Future<void> deleteWorkout(String workoutId) async {
    _workouts.removeWhere((w) => w.workoutId == workoutId);
    notifyListeners();
    await _db.deleteWorkout(workoutId, _currentUserId);
  }
}
