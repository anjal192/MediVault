import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotification,
      );

      _isInitialized = true;
      debugPrint("Local Notifications Initialized Successfully.");
    } catch (e) {
      debugPrint("Notifications Init Error (simulated execution environment): $e");
    }
  }

  void _onDidReceiveNotification(NotificationResponse details) {
    debugPrint("Notification clicked: ${details.id} - ${details.payload}");
  }

  // Request system permissions (e.g. for Android 13+)
  Future<void> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
      final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      debugPrint("Requesting permissions failed: $e");
    }
  }

  // Standard platform channel details
  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'medivault_alerts',
        'MediVault Reminders',
        channelDescription: 'Alerts for medications and consultations',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Show an immediate notification banner
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    try {
      await _notificationsPlugin.show(id, title, body, _getNotificationDetails(), payload: payload);
    } catch (e) {
      debugPrint("Failed to show immediate notification: $e. SIMULATING: $title - $body");
    }
  }

  // Schedule a notification for a future timestamp
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (!_isInitialized) await init();
    if (scheduledDateTime.isBefore(DateTime.now())) {
      debugPrint("Scheduled date is in the past: $scheduledDateTime. Skipping.");
      return;
    }

    try {
      final tzLocation = tz.local;
      final tzScheduledTime = tz.TZDateTime.from(scheduledDateTime, tzLocation);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint("Scheduled notification ID $id at $scheduledDateTime");
    } catch (e) {
      debugPrint("Failed to schedule notification: $e. SIMULATING local alarm for $title at $scheduledDateTime");
    }
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await init();
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint("Cancel notification failed: $e");
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    if (!_isInitialized) await init();
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint("Cancel all failed: $e");
    }
  }

  // --- BUSINESS LOGIC WRAPPERS ---

  // Schedule daily medicine reminders based on timing string (e.g. "08:00 AM")
  Future<void> scheduleMedicineReminder(String id, String medName, String dosage, String timeStr) async {
    try {
      // Parse timing string (e.g. "08:00 AM" or "01:00 PM")
      final parts = timeStr.split(' ');
      if (parts.length < 2) return;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1)); // schedule for tomorrow
      }

      final numericId = id.hashCode;
      await scheduleNotification(
        id: numericId,
        title: "Pill Time! 💊",
        body: "Time to take your $medName ($dosage)",
        scheduledDateTime: scheduledTime,
        payload: "med_reminder:$id",
      );

      // Schedule missed dose alert 30 minutes later
      final missedTime = scheduledTime.add(const Duration(minutes: 30));
      await scheduleNotification(
        id: numericId + 1,
        title: "Missed Medication Alert ⚠️",
        body: "Did you forget to take your $medName? Please record it now.",
        scheduledDateTime: missedTime,
        payload: "missed_alert:$id",
      );
    } catch (e) {
      debugPrint("Failed to set medicine reminder: $e");
    }
  }

  // Schedule low stock alert
  Future<void> scheduleLowStockReminder(String id, String medName, int daysLeft) async {
    if (daysLeft <= 3) {
      final numericId = id.hashCode + 2;
      await showImmediateNotification(
        id: numericId,
        title: "Low Medication Stock ⚠️",
        body: "$medName is running low! Only $daysLeft days left of supply.",
        payload: "low_stock:$id",
      );
    }
  }

  // Schedule consultation appointments reminders
  Future<void> scheduleConsultationReminders(String appointmentId, String doctorName, DateTime apptDateTime) async {
    final numericId = appointmentId.hashCode;

    // Reminders intervals: 7 days, 3 days, 1 day, on the day of
    final intervals = {
      7: "7 days before",
      3: "3 days before",
      1: "tomorrow",
      0: "today"
    };

    for (var entry in intervals.entries) {
      final remDate = apptDateTime.subtract(Duration(days: entry.key));
      // Schedule morning of reminder day
      final scheduledTime = DateTime(remDate.year, remDate.month, remDate.day, 9, 0); 
      
      if (scheduledTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: numericId + entry.key,
          title: "Doctor Appointment Reminder 🩺",
          body: "Consultation with $doctorName is ${entry.value} at ${DateFormat('hh:mm a').format(apptDateTime)}.",
          scheduledDateTime: scheduledTime,
          payload: "appointment:$appointmentId",
        );
      }
    }
  }
}
