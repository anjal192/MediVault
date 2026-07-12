import 'package:flutter/material.dart';
import '../constants/mock_data.dart';
import '../../models/user_model.dart';
import '../../models/medicine_model.dart';
import '../../models/appointment_model.dart';
import '../../models/prescription_model.dart';
import '../../models/tracker_model.dart';
import '../../models/chat_message_model.dart';
import '../../models/notification_model.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/local_notification_service.dart';
import '../../services/ai_gemini_service.dart';

class MediVaultRepository extends ChangeNotifier {
  // In-memory data cache
  final List<Medicine> _medicines = [];
  final List<DoctorAppointment> _appointments = [];
  final List<HealthMetric> _trackerLogs = [];
  final List<PrescriptionVaultItem> _prescriptions = [];
  final List<ChatMessage> _chatHistory = [];
  HealthRecord _healthRecord = HealthRecord(
    bloodGroup: 'O+',
    allergies: [],
    chronicDiseases: [],
    pastSurgeries: [],
    vaccinations: [],
    emergencyContacts: [],
  );

  // Active User session values
  String userEmail = "john.doe@medivault.com";
  String userName = "John Doe";
  int profileCompletion = 85;
  double healthScore = 92;

  // Singleton instance
  static final MediVaultRepository _instance = MediVaultRepository._internal();
  factory MediVaultRepository() => _instance;
  
  MediVaultRepository._internal() {
    // Initial loading or fallback initialization
    _loadDefaultMockData();
    // Try to trigger initial sync if user already logged in
    syncFromFirebase();
  }

  // Set default local lists
  void _loadDefaultMockData() {
    _medicines.clear();
    _medicines.addAll(MockDatabase.medicines);
    _appointments.clear();
    _appointments.addAll(MockDatabase.appointments);
    _trackerLogs.clear();
    _trackerLogs.addAll(MockDatabase.trackerLogs);
    _prescriptions.clear();
    _prescriptions.addAll(MockDatabase.prescriptions);
    _chatHistory.clear();
    _chatHistory.addAll(MockDatabase.chatHistory);
    _healthRecord = MockDatabase.healthRecord;
  }

  // Getters
  List<Medicine> get medicines => _medicines;
  List<DoctorAppointment> get appointments => _appointments.where((a) => a.isUpcoming).toList();
  List<HealthMetric> get trackerLogs => _trackerLogs;
  List<PrescriptionVaultItem> get prescriptions => _prescriptions;
  List<ChatMessage> get chatHistory => _chatHistory;
  HealthRecord get healthRecord => _healthRecord;

  // Daily active schedule
  List<Medicine> get todayMedicines {
    return _medicines.where((m) => !m.isCompleted && !m.isExpired).toList();
  }

  double get adherenceProgress {
    final active = todayMedicines;
    if (active.isEmpty) return 1.0;
    final taken = active.where((m) => m.isTaken).length;
    return taken / active.length;
  }

  List<Medicine> get lowStockMedicines {
    return _medicines.where((m) => m.stockStatus != 'Green' && !m.isCompleted).toList();
  }

  // --- FIREBASE SYNCHRONIZATION ---

  Future<void> syncFromFirebase() async {
    final uid = FirebaseAuthService().currentUid;
    if (uid == null || !FirebaseAuthService().isLoggedIn) {
      debugPrint("No active Firebase session. Keeping local cache.");
      return;
    }

    try {
      userEmail = FirebaseAuthService().currentUserEmail ?? "john.doe@medivault.com";

      // 1. Fetch Profile
      final profile = await FirestoreService().getUserProfile(uid);
      if (profile != null) {
        userName = profile.name;
        profileCompletion = profile.profileCompletion;
        healthScore = profile.healthScore;
        _healthRecord = HealthRecord(
          bloodGroup: profile.bloodGroup,
          allergies: profile.foodAllergies + profile.medicineAllergies,
          chronicDiseases: profile.familyHistory, // map family history / diagnosis
          pastSurgeries: profile.pastSurgeries,
          vaccinations: profile.vaccinations,
          emergencyContacts: profile.emergencyContacts
              .map((c) => EmergencyContact(name: c.name, relation: c.relation, phone: c.phone))
              .toList(),
        );
      } else {
        // Create initial profile in Firestore using mock baseline
        final newProfile = UserModel(
          uid: uid,
          name: userName,
          email: userEmail,
          bloodGroup: _healthRecord.bloodGroup,
          foodAllergies: _healthRecord.allergies,
          emergencyContacts: _healthRecord.emergencyContacts
              .map((c) => EmergencyContactModel(name: c.name, relation: c.relation, phone: c.phone))
              .toList(),
        );
        await FirestoreService().saveUserProfile(newProfile);
      }

      // 2. Fetch Medicines
      final fbMeds = await FirestoreService().getMedicines();
      if (fbMeds.isNotEmpty) {
        _medicines.clear();
        for (var m in fbMeds) {
          _medicines.add(Medicine(
            id: m.id,
            name: m.name,
            dosage: m.dosage,
            time: m.time,
            frequency: m.frequency,
            beforeFood: m.beforeFood,
            isPrescribed: m.isPrescribed,
            doctorName: m.doctorName,
            totalQuantity: m.totalQuantity,
            remainingQuantity: m.remainingQuantity,
            dailyUsage: m.dailyUsage,
            expiryDate: m.expiryDate,
            isTaken: m.isTaken,
            isSkipped: m.isSkipped,
            iconName: m.iconName,
          ));
        }
      } else {
        // Populate Firestore with default medicines
        for (var m in _medicines) {
          await FirestoreService().saveMedicine(MedicineModel(
            id: m.id,
            name: m.name,
            dosage: m.dosage,
            time: m.time,
            frequency: m.frequency,
            beforeFood: m.beforeFood,
            isPrescribed: m.isPrescribed,
            doctorName: m.doctorName,
            totalQuantity: m.totalQuantity,
            remainingQuantity: m.remainingQuantity,
            dailyUsage: m.dailyUsage,
            expiryDate: m.expiryDate,
            isTaken: m.isTaken,
            isSkipped: m.isSkipped,
            iconName: m.iconName,
          ));
        }
      }

      // 3. Fetch Appointments
      final fbAppts = await FirestoreService().getAppointments();
      if (fbAppts.isNotEmpty) {
        _appointments.clear();
        for (var a in fbAppts) {
          _appointments.add(DoctorAppointment(
            id: a.id,
            doctorName: a.doctorName,
            specialty: a.specialty,
            dateTime: a.dateTime,
            location: a.location,
            isUpcoming: a.isUpcoming,
          ));
        }
      } else {
        for (var a in _appointments) {
          await FirestoreService().saveAppointment(AppointmentModel(
            id: a.id,
            doctorName: a.doctorName,
            specialty: a.specialty,
            dateTime: a.dateTime,
            location: a.location,
            isUpcoming: a.isUpcoming,
          ));
        }
      }

      // 4. Fetch Tracker logs
      final fbTracker = await FirestoreService().getTrackerMetrics();
      if (fbTracker.isNotEmpty) {
        _trackerLogs.clear();
        for (var t in fbTracker) {
          _trackerLogs.add(HealthMetric(
            type: t.type,
            value: t.value,
            timestamp: t.timestamp,
            notes: t.notes,
          ));
        }
      } else {
        for (var t in _trackerLogs) {
          await FirestoreService().saveTrackerMetric(TrackerModel(
            id: 'tr_${DateTime.now().millisecondsSinceEpoch}_${t.type}',
            type: t.type,
            value: t.value,
            timestamp: t.timestamp,
            notes: t.notes,
          ));
        }
      }

      // 5. Fetch Prescriptions
      final fbPrescriptions = await FirestoreService().getPrescriptions();
      if (fbPrescriptions.isNotEmpty) {
        _prescriptions.clear();
        for (var p in fbPrescriptions) {
          _prescriptions.add(PrescriptionVaultItem(
            id: p.id,
            doctorName: p.doctorName,
            dateString: p.dateString,
            diagnosis: p.diagnosis,
            notes: p.notes,
            isAIAnalyzed: p.isAIAnalyzed,
            simplifiedMedicines: p.simplifiedMedicines,
          ));
        }
      } else {
        for (var p in _prescriptions) {
          await FirestoreService().savePrescription(PrescriptionModel(
            id: p.id,
            doctorName: p.doctorName,
            dateString: p.dateString,
            diagnosis: p.diagnosis,
            notes: p.notes,
            isAIAnalyzed: p.isAIAnalyzed,
            simplifiedMedicines: p.simplifiedMedicines,
          ));
        }
      }

      // 6. Fetch Chat history
      final fbChat = await FirestoreService().getChatHistory();
      if (fbChat.isNotEmpty) {
        _chatHistory.clear();
        for (var c in fbChat) {
          _chatHistory.add(ChatMessage(
            message: c.message,
            isUser: c.isUser,
            timestamp: c.timestamp,
          ));
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error syncing Firestore: $e");
    }
  }

  // Action: Take medicine
  void takeMedicine(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = _medicines[index];
      if (!med.isTaken) {
        med.isTaken = true;
        med.isSkipped = false;
        
        if (med.remainingQuantity >= med.dailyUsage) {
          med.remainingQuantity -= med.dailyUsage;
        } else {
          med.remainingQuantity = 0;
        }
        
        notifyListeners();

        // Write to Firestore
        FirestoreService().updateMedicineTakeSkipped(id, true, false, med.remainingQuantity);
        FirestoreService().logMedicineEvent(id, med.name, "taken");

        // Schedule refill reminder 3 days before depletion
        if (med.daysLeft <= 3) {
          LocalNotificationService().scheduleLowStockReminder(med.id, med.name, med.daysLeft);
        }
      }
    }
  }

  // Action: Skip medicine
  void skipMedicine(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = _medicines[index];
      med.isSkipped = true;
      med.isTaken = false;
      notifyListeners();

      // Write to Firestore
      FirestoreService().updateMedicineTakeSkipped(id, false, true, med.remainingQuantity);
      FirestoreService().logMedicineEvent(id, med.name, "skipped");
    }
  }

  // Action: Reset all daily taken/skipped values
  void resetDailyMedicines() {
    for (var med in _medicines) {
      med.isTaken = false;
      med.isSkipped = false;
      FirestoreService().updateMedicineTakeSkipped(med.id, false, false, med.remainingQuantity);
    }
    notifyListeners();
  }

  // Action: Add new medicine
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();

    // Write to Firestore
    FirestoreService().saveMedicine(MedicineModel(
      id: medicine.id,
      name: medicine.name,
      dosage: medicine.dosage,
      time: medicine.time,
      frequency: medicine.frequency,
      beforeFood: medicine.beforeFood,
      isPrescribed: medicine.isPrescribed,
      doctorName: medicine.doctorName,
      totalQuantity: medicine.totalQuantity,
      remainingQuantity: medicine.remainingQuantity,
      dailyUsage: medicine.dailyUsage,
      expiryDate: medicine.expiryDate,
      isTaken: medicine.isTaken,
      isSkipped: medicine.isSkipped,
      iconName: medicine.iconName,
    ));

    // Schedule notifications reminder alarm
    LocalNotificationService().scheduleMedicineReminder(
      medicine.id,
      medicine.name,
      medicine.dosage,
      medicine.time,
    );
  }

  // Action: Confirm Reorder
  void confirmReorder(String id, int quantity) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = _medicines[index];
      med.remainingQuantity += quantity;
      med.totalQuantity += quantity;
      notifyListeners();

      // Write to Firestore
      FirestoreService().updateMedicineStock(id, med.remainingQuantity, med.totalQuantity);
    }
  }

  // Action: Update inventory post doctor visit
  void updateInventoryPostDoctorVisit(String medName, int durationDays, int tabletsPurchased, int dailyUsage) {
    final index = _medicines.indexWhere((m) => m.name.toLowerCase().contains(medName.toLowerCase()));
    if (index != -1) {
      final med = _medicines[index];
      med.totalQuantity += tabletsPurchased;
      med.remainingQuantity += tabletsPurchased;
      med.dailyUsage = dailyUsage;
      notifyListeners();

      FirestoreService().updateMedicineStock(med.id, med.remainingQuantity, med.totalQuantity);
    } else {
      final newMed = Medicine(
        id: 'm_gen_${DateTime.now().millisecondsSinceEpoch}',
        name: medName,
        dosage: '1 tablet',
        time: '08:00 AM',
        frequency: 'Daily',
        beforeFood: false,
        isPrescribed: true,
        doctorName: 'Primary Care Doctor',
        totalQuantity: tabletsPurchased,
        remainingQuantity: tabletsPurchased,
        dailyUsage: dailyUsage,
        expiryDate: DateTime.now().add(Duration(days: durationDays + 90)),
        iconName: 'pill',
      );
      addMedicine(newMed);
    }
  }

  // Action: Schedule a new doctor appointment
  void scheduleAppointment(DoctorAppointment appointment) {
    _appointments.add(appointment);
    notifyListeners();

    // Write to Firestore
    FirestoreService().saveAppointment(AppointmentModel(
      id: appointment.id,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      dateTime: appointment.dateTime,
      location: appointment.location,
      isUpcoming: appointment.isUpcoming,
    ));

    // Schedule 7d, 3d, 1d, and day-of consultation reminders
    LocalNotificationService().scheduleConsultationReminders(
      appointment.id,
      appointment.doctorName,
      appointment.dateTime,
    );
  }

  // Action: Add health vitals metric
  void addTrackerMetric(String type, double value, String notes) {
    final metricId = 'tr_${DateTime.now().millisecondsSinceEpoch}_$type';
    _trackerLogs.add(
      HealthMetric(
        type: type,
        value: value,
        timestamp: DateTime.now(),
        notes: notes,
      ),
    );
    notifyListeners();

    // Write to Firestore
    FirestoreService().saveTrackerMetric(TrackerModel(
      id: metricId,
      type: type,
      value: value,
      timestamp: DateTime.now(),
      notes: notes,
    ));
  }

  // Action: Add prescription upload
  void uploadPrescription(PrescriptionVaultItem item) {
    _prescriptions.add(item);
    notifyListeners();

    // Write to Firestore
    FirestoreService().savePrescription(PrescriptionModel(
      id: item.id,
      doctorName: item.doctorName,
      dateString: item.dateString,
      diagnosis: item.diagnosis,
      notes: item.notes,
      isAIAnalyzed: item.isAIAnalyzed,
      simplifiedMedicines: item.simplifiedMedicines,
    ));
  }

  // Action: Post chatbot message
  void sendChatMessage(String messageText) {
    final userMsgId = 'msg_user_${DateTime.now().millisecondsSinceEpoch}';
    final userChat = ChatMessage(message: messageText, isUser: true, timestamp: DateTime.now());
    _chatHistory.add(userChat);
    notifyListeners();

    // Write to Firestore
    FirestoreService().saveChatMessage(ChatMessageModel(
      id: userMsgId,
      message: messageText,
      isUser: true,
      timestamp: userChat.timestamp,
    ));

    // Call Gemini AI service
    Future.delayed(const Duration(milliseconds: 200), () async {
      final historyList = _chatHistory.map((c) => {
        'role': c.isUser ? 'user' : 'model',
        'message': c.message
      }).toList();

      final responseText = await AIGeminiService().askChatbot(messageText, historyList);
      
      final aiMsgId = 'msg_ai_${DateTime.now().millisecondsSinceEpoch}';
      final aiChat = ChatMessage(message: responseText, isUser: false, timestamp: DateTime.now());
      _chatHistory.add(aiChat);
      notifyListeners();

      // Write AI response to Firestore
      FirestoreService().saveChatMessage(ChatMessageModel(
        id: aiMsgId,
        message: responseText,
        isUser: false,
        timestamp: aiChat.timestamp,
      ));
    });
  }
}
