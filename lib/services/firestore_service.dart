import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/appointment_model.dart';
import '../models/prescription_model.dart';
import '../models/tracker_model.dart';
import '../models/chat_message_model.dart';
import '../models/notification_model.dart';
import 'firebase_auth_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore not initialized: $e");
      return null;
    }
  }

  String get _uid => FirebaseAuthService().currentUid ?? "john_doe_uid";

  // --- USER PROFILE ---
  Future<void> saveUserProfile(UserModel user) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final db = _firestore;
    if (db == null) return null;
    final doc = await db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  /// Partially update user profile fields (name, age, weight, height, allergies, etc.)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> fields) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('users').doc(uid).update(fields);
  }

  // --- MEDICINES ---
  Future<void> saveMedicine(MedicineModel medicine) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap(), SetOptions(merge: true));
  }

  Future<List<MedicineModel>> getMedicines() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db.collection('users').doc(_uid).collection('medicines').get();
    return snapshot.docs.map((doc) => MedicineModel.fromMap(doc.data())).toList();
  }

  Future<void> updateMedicineTakeSkipped(String medId, bool isTaken, bool isSkipped, int remainingQuantity) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('users').doc(_uid).collection('medicines').doc(medId).update({
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'remainingQuantity': remainingQuantity,
    });
  }

  Future<void> updateMedicineStock(String medId, int remainingQuantity, int totalQuantity) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('users').doc(_uid).collection('medicines').doc(medId).update({
      'remainingQuantity': remainingQuantity,
      'totalQuantity': totalQuantity,
    });
  }

  // --- MEDICINE LOGS ---
  Future<void> logMedicineEvent(String medId, String medName, String action) async {
    final db = _firestore;
    if (db == null) return;
    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
    await db.collection('users').doc(_uid).collection('medicine_logs').doc(logId).set({
      'id': logId,
      'medicineId': medId,
      'medicineName': medName,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- APPOINTMENTS ---
  Future<void> saveAppointment(AppointmentModel appointment) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap(), SetOptions(merge: true));
  }

  Future<List<AppointmentModel>> getAppointments() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db.collection('users').doc(_uid).collection('appointments').get();
    return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data())).toList();
  }

  // --- TRACKER METRICS ---
  Future<void> saveTrackerMetric(TrackerModel metric) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('tracker_logs')
        .doc(metric.id)
        .set(metric.toMap(), SetOptions(merge: true));
  }

  Future<List<TrackerModel>> getTrackerMetrics() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db.collection('users').doc(_uid).collection('tracker_logs').get();
    return snapshot.docs.map((doc) => TrackerModel.fromMap(doc.data())).toList();
  }

  // --- PRESCRIPTIONS ---
  Future<void> savePrescription(PrescriptionModel prescription) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('prescriptions')
        .doc(prescription.id)
        .set(prescription.toMap(), SetOptions(merge: true));
  }

  Future<List<PrescriptionModel>> getPrescriptions() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db.collection('users').doc(_uid).collection('prescriptions').get();
    return snapshot.docs.map((doc) => PrescriptionModel.fromMap(doc.data())).toList();
  }

  // --- MEDICAL RECORDS ---
  Future<void> saveMedicalRecord(MedicalRecordModel record) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('medical_records')
        .doc(record.id)
        .set(record.toMap(), SetOptions(merge: true));
  }

  Future<List<MedicalRecordModel>> getMedicalRecords() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db.collection('users').doc(_uid).collection('medical_records').get();
    return snapshot.docs.map((doc) => MedicalRecordModel.fromMap(doc.data())).toList();
  }

  // --- CHAT HISTORY ---
  Future<void> saveChatMessage(ChatMessageModel message) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('chat_history')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<List<ChatMessageModel>> getChatHistory() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db
        .collection('users')
        .doc(_uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: false)
        .get();
    return snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.data())).toList();
  }

  // --- NOTIFICATIONS ---
  Future<void> saveNotification(NotificationModel notification) async {
    final db = _firestore;
    if (db == null) return;
    await db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<List<NotificationModel>> getNotifications() async {
    final db = _firestore;
    if (db == null) return [];
    final snapshot = await db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }

  Future<void> markNotificationsAsRead() async {
    final db = _firestore;
    if (db == null) return;
    final batch = db.batch();
    final snapshot = await db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notifId) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('users').doc(_uid).collection('notifications').doc(notifId).delete();
  }
}
