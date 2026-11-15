import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentUserId = '';

  Future<void> loadReminders(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    await _notificationService.initialize();
    _reminders = await _db.getReminders(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder(String reminderId, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.reminderId == reminderId);
    if (index == -1) return;

    final updated = _reminders[index].copyWith(isEnabled: isEnabled);
    _reminders[index] = updated;
    notifyListeners();

    await _db.saveReminder(updated);

    if (isEnabled) {
      // Schedule reminder
      final parts = updated.reminderTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      await _notificationService.scheduleDailyReminder(
        id: updated.notificationId,
        title: updated.title,
        body: updated.message,
        hour: hour,
        minute: min,
      );
    } else {
      await _notificationService.cancelReminder(updated.notificationId);
    }
  }

  Future<void> updateReminderTime(String reminderId, String newTime) async {
    final index = _reminders.indexWhere((r) => r.reminderId == reminderId);
    if (index == -1) return;

    final updated = _reminders[index].copyWith(reminderTime: newTime);
    _reminders[index] = updated;
    notifyListeners();

    await _db.saveReminder(updated);

    if (updated.isEnabled) {
      final parts = newTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      await _notificationService.scheduleDailyReminder(
        id: updated.notificationId,
        title: updated.title,
        body: updated.message,
        hour: hour,
        minute: min,
      );
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.add(reminder);
    notifyListeners();
    await _db.saveReminder(reminder);

    if (reminder.isEnabled) {
      final parts = reminder.reminderTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      await _notificationService.scheduleDailyReminder(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.message,
        hour: hour,
        minute: min,
      );
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.reminderId == reminderId);
    if (index != -1) {
      final notifId = _reminders[index].notificationId;
      await _notificationService.cancelReminder(notifId);
    }

    _reminders.removeWhere((r) => r.reminderId == reminderId);
    notifyListeners();
    await _db.deleteReminder(reminderId, _currentUserId);
  }

  Future<void> sendTestNotification() async {
    await _notificationService.requestPermissions();
    await _notificationService.showNotification(
      id: 999,
      title: 'VitaTrack Alert 🌿',
      body: 'Your notification system is fully operational and active!',
    );
  }
}
