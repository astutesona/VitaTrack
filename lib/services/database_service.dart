import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/health_record.dart';
import '../models/workout.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  FirebaseFirestore? _firestore;
  bool _firestoreAvailable = false;

  void initialize() {
    try {
      _firestore = FirebaseFirestore.instance;
      _firestoreAvailable = true;
      debugPrint('DatabaseService: Cloud Firestore initialized.');
    } catch (e) {
      _firestoreAvailable = false;
      debugPrint('DatabaseService: Cloud Firestore unavailable ($e). Using local persistence.');
    }
  }

  // ================= USER PROFILE =================

  Future<UserProfile?> getUserProfile(String userId) async {
    if (_firestoreAvailable && _firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final profile = UserProfile.fromMap(doc.data()!, id: doc.id);
          await _saveProfileLocally(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('Firestore getUserProfile error: $e');
      }
    }

    // Fallback to local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cache_user_$userId');
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr);
        return UserProfile.fromMap(map, id: userId);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _saveProfileLocally(profile);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(profile.userId)
            .set(profile.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore saveUserProfile error: $e');
      }
    }
  }

  Future<void> _saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cache_user_${profile.userId}',
      jsonEncode(profile.toMap()),
    );
  }

  // ================= HEALTH RECORDS =================

  Future<HealthRecord?> getHealthRecord(String userId, String date) async {
    final recordId = '${userId}_$date';

    if (_firestoreAvailable && _firestore != null) {
      try {
        final doc =
            await _firestore!.collection('health_records').doc(recordId).get();
        if (doc.exists && doc.data() != null) {
          final record = HealthRecord.fromMap(doc.data()!, id: doc.id);
          await _saveHealthRecordLocally(record);
          return record;
        }
      } catch (e) {
        debugPrint('Firestore getHealthRecord error: $e');
      }
    }

    // Local fallback
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cache_record_$recordId');
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr);
        return HealthRecord.fromMap(map, id: recordId);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    await _saveHealthRecordLocally(record);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!
            .collection('health_records')
            .doc(record.id)
            .set(record.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore saveHealthRecord error: $e');
      }
    }
  }

  Future<void> _saveHealthRecordLocally(HealthRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cache_record_${record.id}',
      jsonEncode(record.toMap()),
    );

    // Also update record keys index
    List<String> keys = prefs.getStringList('user_records_${record.userId}') ?? [];
    if (!keys.contains(record.date)) {
      keys.add(record.date);
      await prefs.setStringList('user_records_${record.userId}', keys);
    }
  }

  Future<List<HealthRecord>> getRecentHealthRecords(
      String userId, int days) async {
    List<HealthRecord> records = [];

    if (_firestoreAvailable && _firestore != null) {
      try {
        final query = await _firestore!
            .collection('health_records')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .limit(days)
            .get();

        records = query.docs
            .map((doc) => HealthRecord.fromMap(doc.data(), id: doc.id))
            .toList();

        if (records.isNotEmpty) return records;
      } catch (e) {
        debugPrint('Firestore getRecentHealthRecords error: $e');
      }
    }

    // Local fallback: read indexed dates
    final prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getStringList('user_records_$userId') ?? [];
    keys.sort((a, b) => b.compareTo(a)); // Descending

    for (final date in keys.take(days)) {
      final jsonStr = prefs.getString('cache_record_${userId}_$date');
      if (jsonStr != null) {
        try {
          final map = jsonDecode(jsonStr);
          records.add(HealthRecord.fromMap(map, id: '${userId}_$date'));
        } catch (_) {}
      }
    }

    return records;
  }

  // ================= WORKOUTS =================

  Future<List<Workout>> getWorkouts(String userId) async {
    if (_firestoreAvailable && _firestore != null) {
      try {
        final query = await _firestore!
            .collection('workouts')
            .where('userId', isEqualTo: userId)
            .orderBy('workoutDate', descending: true)
            .get();

        final list = query.docs
            .map((doc) => Workout.fromMap(doc.data(), id: doc.id))
            .toList();
        await _saveWorkoutsLocally(userId, list);
        return list;
      } catch (e) {
        debugPrint('Firestore getWorkouts error: $e');
      }
    }

    // Local fallback
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cache_workouts_$userId');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => Workout.fromMap(Map<String, dynamic>.from(item))).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> addWorkout(Workout workout) async {
    // Add to local list
    final existing = await getWorkouts(workout.userId);
    existing.insert(0, workout);
    await _saveWorkoutsLocally(workout.userId, existing);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!
            .collection('workouts')
            .doc(workout.workoutId)
            .set(workout.toMap());
      } catch (e) {
        debugPrint('Firestore addWorkout error: $e');
      }
    }
  }

  Future<void> deleteWorkout(String workoutId, String userId) async {
    final existing = await getWorkouts(userId);
    existing.removeWhere((w) => w.workoutId == workoutId);
    await _saveWorkoutsLocally(userId, existing);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!.collection('workouts').doc(workoutId).delete();
      } catch (e) {
        debugPrint('Firestore deleteWorkout error: $e');
      }
    }
  }

  Future<void> _saveWorkoutsLocally(String userId, List<Workout> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((w) => w.toMap()).toList();
    await prefs.setString('cache_workouts_$userId', jsonEncode(jsonList));
  }

  // ================= REMINDERS =================

  Future<List<ReminderModel>> getReminders(String userId) async {
    if (_firestoreAvailable && _firestore != null) {
      try {
        final query = await _firestore!
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .get();

        final list = query.docs
            .map((doc) => ReminderModel.fromMap(doc.data(), id: doc.id))
            .toList();
        await _saveRemindersLocally(userId, list);
        return list;
      } catch (e) {
        debugPrint('Firestore getReminders error: $e');
      }
    }

    // Local fallback
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cache_reminders_$userId');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list
            .map((item) =>
                ReminderModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {}
    }

    // Default reminders if none exist
    final defaults = [
      ReminderModel(
        reminderId: 'rem_water_1',
        userId: userId,
        reminderType: 'Water',
        reminderTime: '09:00',
        isEnabled: true,
        title: 'Hydration Time 💧',
        message: 'Drink a glass of water (250 ml) to stay energetic!',
        notificationId: 101,
      ),
      ReminderModel(
        reminderId: 'rem_water_2',
        userId: userId,
        reminderType: 'Water',
        reminderTime: '14:30',
        isEnabled: true,
        title: 'Afternoon Hydration 💧',
        message: 'Keep your body hydrated throughout your day!',
        notificationId: 102,
      ),
      ReminderModel(
        reminderId: 'rem_walk_1',
        userId: userId,
        reminderType: 'Walking',
        reminderTime: '11:00',
        isEnabled: true,
        title: 'Step Break 🚶‍♂️',
        message: 'Time for a 5-minute walk to hit your step goal!',
        notificationId: 201,
      ),
      ReminderModel(
        reminderId: 'rem_sleep_1',
        userId: userId,
        reminderType: 'Sleep',
        reminderTime: '22:30',
        isEnabled: true,
        title: 'Bedtime Routine 🌙',
        message: 'Wind down and prepare for a healthy night of sleep.',
        notificationId: 301,
      ),
    ];
    await _saveRemindersLocally(userId, defaults);
    return defaults;
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    final existing = await getReminders(reminder.userId);
    final index =
        existing.indexWhere((r) => r.reminderId == reminder.reminderId);
    if (index >= 0) {
      existing[index] = reminder;
    } else {
      existing.add(reminder);
    }
    await _saveRemindersLocally(reminder.userId, existing);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!
            .collection('reminders')
            .doc(reminder.reminderId)
            .set(reminder.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore saveReminder error: $e');
      }
    }
  }

  Future<void> deleteReminder(String reminderId, String userId) async {
    final existing = await getReminders(userId);
    existing.removeWhere((r) => r.reminderId == reminderId);
    await _saveRemindersLocally(userId, existing);

    if (_firestoreAvailable && _firestore != null) {
      try {
        await _firestore!.collection('reminders').doc(reminderId).delete();
      } catch (e) {
        debugPrint('Firestore deleteReminder error: $e');
      }
    }
  }

  Future<void> _saveRemindersLocally(
      String userId, List<ReminderModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((r) => r.toMap()).toList();
    await prefs.setString('cache_reminders_$userId', jsonEncode(jsonList));
  }
}
