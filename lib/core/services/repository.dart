import 'package:flutter/material.dart';
import '../constants/mock_data.dart';

class MediVaultRepository extends ChangeNotifier {
  // In-memory data lists referenced from MockDatabase
  final List<Medicine> _medicines = List.from(MockDatabase.medicines);
  final List<DoctorAppointment> _appointments = List.from(MockDatabase.appointments);
  final List<HealthMetric> _trackerLogs = List.from(MockDatabase.trackerLogs);
  final List<PrescriptionVaultItem> _prescriptions = List.from(MockDatabase.prescriptions);
  final List<ChatMessage> _chatHistory = List.from(MockDatabase.chatHistory);
  final HealthRecord _healthRecord = MockDatabase.healthRecord;

  // Active User session (simulated)
  String userEmail = "john.doe@medivault.com";
  String userName = "John Doe";
  int profileCompletion = 85; // 85% completion
  double healthScore = 92; // 92/100 score

  // Singleton instance
  static final MediVaultRepository _instance = MediVaultRepository._internal();
  factory MediVaultRepository() => _instance;
  MediVaultRepository._internal();

  // Getters
  List<Medicine> get medicines => _medicines;
  List<DoctorAppointment> get appointments => _appointments.where((a) => a.isUpcoming).toList();
  List<HealthMetric> get trackerLogs => _trackerLogs;
  List<PrescriptionVaultItem> get prescriptions => _prescriptions;
  List<ChatMessage> get chatHistory => _chatHistory;
  HealthRecord get healthRecord => _healthRecord;

  // Get count of today's medicines
  List<Medicine> get todayMedicines {
    // Exclude completed or expired medicines from active daily schedule
    return _medicines.where((m) => !m.isCompleted && !m.isExpired).toList();
  }

  // Calculate Adherence progress: taken / total today
  double get adherenceProgress {
    final active = todayMedicines;
    if (active.isEmpty) return 1.0;
    final taken = active.where((m) => m.isTaken).length;
    return taken / active.length;
  }

  // Get low stock alert items
  List<Medicine> get lowStockMedicines {
    return _medicines.where((m) => m.stockStatus != 'Green' && !m.isCompleted).toList();
  }

  // Action: Take medicine
  void takeMedicine(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = _medicines[index];
      if (!med.isTaken) {
        med.isTaken = true;
        med.isSkipped = false;
        // Decrement stock
        if (med.remainingQuantity >= med.dailyUsage) {
          med.remainingQuantity -= med.dailyUsage;
        } else {
          med.remainingQuantity = 0;
        }
        notifyListeners();
      }
    }
  }

  // Action: Skip medicine
  void skipMedicine(String id) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medicines[index].isSkipped = true;
      _medicines[index].isTaken = false;
      notifyListeners();
    }
  }

  // Action: Reset all daily taken/skipped values (simulated morning reset)
  void resetDailyMedicines() {
    for (var med in _medicines) {
      med.isTaken = false;
      med.isSkipped = false;
    }
    notifyListeners();
  }

  // Action: Add a new medicine (Add Medicine Screen)
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();
  }

  // Action: Confirm Reorder (Smart Inventory low stock alert)
  void confirmReorder(String id, int quantity) {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medicines[index].remainingQuantity += quantity;
      _medicines[index].totalQuantity += quantity;
      notifyListeners();
    }
  }

  // Action: Update inventory post doctor visit
  void updateInventoryPostDoctorVisit(String medName, int durationDays, int tabletsPurchased, int dailyUsage) {
    // Look if medicine exists, otherwise add it
    final index = _medicines.indexWhere((m) => m.name.toLowerCase().contains(medName.toLowerCase()));
    if (index != -1) {
      _medicines[index].totalQuantity += tabletsPurchased;
      _medicines[index].remainingQuantity += tabletsPurchased;
      _medicines[index].dailyUsage = dailyUsage;
    } else {
      // Create new medicine
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
      _medicines.add(newMed);
    }
    notifyListeners();
  }

  // Action: Schedule a new doctor appointment
  void scheduleAppointment(DoctorAppointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  // Action: Add a health tracker log
  void addTrackerMetric(String type, double value, String notes) {
    _trackerLogs.add(
      HealthMetric(
        type: type,
        value: value,
        timestamp: DateTime.now(),
        notes: notes,
      ),
    );
    notifyListeners();
  }

  // Action: Add simplified prescription to vault
  void uploadPrescription(PrescriptionVaultItem item) {
    _prescriptions.add(item);
    notifyListeners();
  }

  // Action: Post message to AI Assistant
  void sendChatMessage(String messageText) {
    _chatHistory.add(ChatMessage(message: messageText, isUser: true, timestamp: DateTime.now()));
    notifyListeners();
    
    // Simulate AI typing delay and response
    Future.delayed(const Duration(milliseconds: 1000), () {
      final responseText = _generateAIResponse(messageText);
      _chatHistory.add(ChatMessage(message: responseText, isUser: false, timestamp: DateTime.now()));
      notifyListeners();
    });
  }

  // AI Response generator (simulated helper)
  String _generateAIResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello John! I hope you are feeling well. How can I assist you with your medications or symptoms today?';
    }
    if (lower.contains('lipitor') || lower.contains('atorvastatin')) {
      return 'Atorvastatin (Lipitor) is a cholesterol-lowering medication. It is usually taken once a day in the evening. Common side effects include mild muscle pain, joint discomfort, or headache. Avoid eating grapefruits, as it can increase the concentration of the medicine in your body.';
    }
    if (lower.contains('metformin') || lower.contains('sugar')) {
      return 'Metformin is prescribed to help regulate blood sugar levels in type 2 diabetes. It works by making your body more sensitive to insulin. Take it WITH or AFTER meals to minimize digestive side effects like bloating, nausea, or stomach upset.';
    }
    if (lower.contains('interaction') || lower.contains('mix')) {
      return 'Let me analyze your active medications. Currently, you take Lipitor and Metformin. There are no major documented drug-drug interactions between Lipitor and Metformin. However, always consult your physician if you experience any muscle weakness or stomach pain.';
    }
    if (lower.contains('emergency') || lower.contains('hospital')) {
      return 'If you are experiencing severe chest pain, shortness of breath, or a medical crisis, please open the Emergency Card from your dashboard and contact emergency services immediately.';
    }
    return 'I hear you. To give you the best assistance, could you clarify which medication or health symptom you are asking about? (You can also ask: "What are the side effects of Metformin?" or "Does Lipitor interact with Metformin?")';
  }
}
