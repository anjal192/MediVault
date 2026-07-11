import 'package:flutter/material.dart';
import 'repository.dart';
import 'voice_service.dart';
import '../constants/mock_data.dart';

enum NotificationType {
  medicineReminder,
  lowStock,
  doctorAppointment,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  AppNotification? activeOverlayNotification; // Current notification shown as a banner

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();

  // Helper: Trigger a new simulated notification banner
  void triggerNotification(String title, String body, NotificationType type, {Map<String, dynamic> metadata = const {}}) {
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
    
    _notifications.insert(0, notification);
    activeOverlayNotification = notification;
    notifyListeners();

    // Trigger Speech TTS automatically if it's a medicine reminder
    if (type == NotificationType.medicineReminder) {
      final medName = metadata['medName'] ?? "Medication";
      final dosage = metadata['dosage'] ?? "dosage";
      VoiceService().speakMedicationReminder(medName, dosage, "Please take your dose.");
    }
  }

  // Dismiss overlay banner
  void dismissActiveOverlay() {
    if (activeOverlayNotification != null) {
      activeOverlayNotification!.isRead = true;
      activeOverlayNotification = null;
      notifyListeners();
    }
  }

  // Clear notification by ID
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    if (activeOverlayNotification?.id == id) {
      activeOverlayNotification = null;
    }
    notifyListeners();
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notif in _notifications) {
      notif.isRead = true;
    }
    notifyListeners();
  }

  // Action: Simulating a Medicine Reminder notification
  void simulateMedicineReminder(Medicine med) {
    triggerNotification(
      "Medicine Reminder 🔔",
      "Time to take: ${med.name} (${med.dosage}) - ${med.beforeFood ? "Before Food" : "After Food"}",
      NotificationType.medicineReminder,
      metadata: {
        'medId': med.id,
        'medName': med.name,
        'dosage': med.dosage,
      },
    );
  }

  // Action: Simulating Low Stock Notification
  void simulateLowStockAlert(Medicine med) {
    triggerNotification(
      "Low Medicine Stock ⚠️",
      "${med.name} is running low! Only ${med.remainingQuantity} remaining. Click here to confirm reorder of ${med.totalQuantity} tablets.",
      NotificationType.lowStock,
      metadata: {
        'medId': med.id,
        'medName': med.name,
        'reorderQty': med.totalQuantity, // Suggesting same amount as original purchase
      },
    );
  }

  // Action: Simulating Doctor Appointment Reminder / Visit Completed
  void simulateDoctorVisitReminder(DoctorAppointment appt) {
    triggerNotification(
      "Doctor Visit Completed 🩺",
      "Your visit with ${appt.doctorName} has finished. Please click to update your medication inventory and log your next visit.",
      NotificationType.doctorAppointment,
      metadata: {
        'apptId': appt.id,
        'doctorName': appt.doctorName,
      },
    );
  }

  // Action: Confirm Order (Low stock reorder confirmation)
  void handleReorderConfirm(String medId, int reorderQty) {
    MediVaultRepository().confirmReorder(medId, reorderQty);
    dismissActiveOverlay();
    
    // Add success confirmation notification
    triggerNotification(
      "Reorder Confirmed ✅",
      "Successfully added $reorderQty tablets to your inventory.",
      NotificationType.medicineReminder,
    );
  }
}
