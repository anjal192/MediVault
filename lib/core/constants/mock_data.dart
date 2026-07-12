
// ==========================================
// 1. MEDICINE MODEL
// ==========================================
class Medicine {
  final String id;
  final String name;
  final String dosage;      // e.g. "1 Tablet", "5ml"
  final String time;        // e.g. "08:00 AM"
  final String frequency;   // e.g. "Daily", "Twice Daily"
  final bool beforeFood;    // true = Before Food, false = After Food
  final bool isPrescribed;
  final String? doctorName; // Name of prescribing doctor
  
  int totalQuantity;        // Purchased count
  int remainingQuantity;    // Available count
  int dailyUsage;           // Pills consumed per day
  final DateTime expiryDate;
  
  bool isTaken;             // Today's state (simulated)
  bool isSkipped;           // Today's state (simulated)
  
  // Simulated visual icon name
  final String iconName;    // "pill", "tablet", "syrup", "capsule"

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.beforeFood,
    required this.isPrescribed,
    this.doctorName,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.dailyUsage,
    required this.expiryDate,
    this.isTaken = false,
    this.isSkipped = false,
    required this.iconName,
  });

  // Automatically calculate days left
  int get daysLeft {
    if (dailyUsage <= 0) return 365; // default fallback
    return (remainingQuantity / dailyUsage).floor();
  }

  // Get stock status level: Green (Enough), Yellow (Low), Red (Critical)
  String get stockStatus {
    int days = daysLeft;
    if (days <= 3) return 'Red';     // Critical
    if (days <= 7) return 'Yellow';  // Low
    return 'Green';                 // Enough
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  bool get isCompleted {
    return remainingQuantity <= 0;
  }

  // Firebase integration mapping
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time,
      'frequency': frequency,
      'beforeFood': beforeFood,
      'isPrescribed': isPrescribed,
      'doctorName': doctorName,
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'dailyUsage': dailyUsage,
      'expiryDate': expiryDate.toIso8601String(),
      'iconName': iconName,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      time: map['time'],
      frequency: map['frequency'],
      beforeFood: map['beforeFood'],
      isPrescribed: map['isPrescribed'],
      doctorName: map['doctorName'],
      totalQuantity: map['totalQuantity'],
      remainingQuantity: map['remainingQuantity'],
      dailyUsage: map['dailyUsage'],
      expiryDate: DateTime.parse(map['expiryDate']),
      iconName: map['iconName'] ?? 'pill',
    );
  }
}

// ==========================================
// 2. DOCTOR APPOINTMENT MODEL
// ==========================================
class DoctorAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final bool isUpcoming;

  DoctorAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.location,
    this.isUpcoming = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctorName': doctorName,
    'specialty': specialty,
    'dateTime': dateTime.toIso8601String(),
    'location': location,
    'isUpcoming': isUpcoming,
  };

  factory DoctorAppointment.fromMap(Map<String, dynamic> map) => DoctorAppointment(
    id: map['id'],
    doctorName: map['doctorName'],
    specialty: map['specialty'],
    dateTime: DateTime.parse(map['dateTime']),
    location: map['location'],
    isUpcoming: map['isUpcoming'] ?? true,
  );
}

// ==========================================
// 3. HEALTH RECORD MODEL
// ==========================================
class HealthRecord {
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicDiseases;
  final List<String> pastSurgeries;
  final List<String> vaccinations;
  final List<EmergencyContact> emergencyContacts;

  HealthRecord({
    required this.bloodGroup,
    required this.allergies,
    required this.chronicDiseases,
    required this.pastSurgeries,
    required this.vaccinations,
    required this.emergencyContacts,
  });
}

class EmergencyContact {
  final String name;
  final String relation;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });
}

// ==========================================
// 4. HEALTH METRIC MODEL (TRACKER)
// ==========================================
class HealthMetric {
  final String type; // "BP_SYS", "BP_DIA", "SUGAR", "WEIGHT", "HEART_RATE", "SPO2", "TEMP"
  final double value;
  final DateTime timestamp;
  final String notes;

  HealthMetric({
    required this.type,
    required this.value,
    required this.timestamp,
    this.notes = '',
  });
}

// ==========================================
// 5. PRESCRIPTION VAULT MODEL
// ==========================================
class PrescriptionVaultItem {
  final String id;
  final String doctorName;
  final String dateString;
  final String diagnosis;
  final String notes;
  final bool isAIAnalyzed;
  final List<String> simplifiedMedicines;

  PrescriptionVaultItem({
    required this.id,
    required this.doctorName,
    required this.dateString,
    required this.diagnosis,
    required this.notes,
    required this.isAIAnalyzed,
    required this.simplifiedMedicines,
  });
}

// ==========================================
// 6. CHAT MESSAGE MODEL (AI CHAT)
// ==========================================
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

// ==========================================
// 7. INITIAL DUMMY DATABASE INITIALIZATION
// ==========================================
class MockDatabase {
  MockDatabase._();

  static List<Medicine> medicines = [
    Medicine(
      id: 'm1',
      name: 'Atorvastatin (Lipitor)',
      dosage: '10 mg',
      time: '08:00 AM',
      frequency: 'Daily',
      beforeFood: false,
      isPrescribed: true,
      doctorName: 'Dr. Sarah Jenkins (Cardiologist)',
      totalQuantity: 30,
      remainingQuantity: 12,
      dailyUsage: 1,
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      iconName: 'capsule',
    ),
    Medicine(
      id: 'm2',
      name: 'Metformin HCl',
      dosage: '500 mg',
      time: '01:00 PM',
      frequency: 'Daily',
      beforeFood: false,
      isPrescribed: true,
      doctorName: 'Dr. Robert Chen (Endocrinologist)',
      totalQuantity: 60,
      remainingQuantity: 4,
      dailyUsage: 2,
      expiryDate: DateTime.now().add(const Duration(days: 120)),
      iconName: 'tablet',
    ),
    Medicine(
      id: 'm3',
      name: 'Amoxicillin Trihydrate',
      dosage: '250 mg',
      time: '09:00 PM',
      frequency: 'Three Times Daily',
      beforeFood: true,
      isPrescribed: true,
      doctorName: 'Dr. Sarah Jenkins',
      totalQuantity: 21,
      remainingQuantity: 1, // Critical
      dailyUsage: 3,
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      iconName: 'capsule',
    ),
    Medicine(
      id: 'm4',
      name: 'Multivitamin Supplements',
      dosage: '1 Capsule',
      time: '08:00 AM',
      frequency: 'Daily',
      beforeFood: true,
      isPrescribed: false,
      totalQuantity: 90,
      remainingQuantity: 75, // Enough
      dailyUsage: 1,
      expiryDate: DateTime.now().subtract(const Duration(days: 5)), // Expired
      iconName: 'pill',
    ),
    Medicine(
      id: 'm5',
      name: 'Lisinopril',
      dosage: '5 mg',
      time: '08:00 AM',
      frequency: 'Daily',
      beforeFood: false,
      isPrescribed: true,
      doctorName: 'Dr. Sarah Jenkins',
      totalQuantity: 30,
      remainingQuantity: 0, // Completed
      dailyUsage: 1,
      expiryDate: DateTime.now().add(const Duration(days: 200)),
      iconName: 'tablet',
    ),
  ];

  static List<DoctorAppointment> appointments = [
    DoctorAppointment(
      id: 'a1',
      doctorName: 'Dr. Sarah Jenkins',
      specialty: 'Cardiology Specialist',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      location: 'Grace Cardiac Clinic, Suite 402',
    ),
    DoctorAppointment(
      id: 'a2',
      doctorName: 'Dr. Robert Chen',
      specialty: 'Endocrinology & Diabetes Care',
      dateTime: DateTime.now().add(const Duration(days: 14, hours: 2)),
      location: 'Metabolic Wellness Center, Room 10B',
    )
  ];

  static HealthRecord healthRecord = HealthRecord(
    bloodGroup: 'O-Negative (O-)',
    allergies: ['Penicillin G', 'Peanuts', 'Sulfa Drugs'],
    chronicDiseases: ['Type 2 Diabetes Mellitus', 'Essential Hypertension'],
    pastSurgeries: ['Appendectomy (2018)', 'Knee Arthroscopy (2022)'],
    vaccinations: ['COVID-19 Booster (Oct 2024)', 'Influenza Vaccine (Oct 2025)', 'Tetanus Toxoid (2020)'],
    emergencyContacts: [
      EmergencyContact(name: 'Jane Doe', relation: 'Spouse', phone: '+1 (555) 019-2834'),
      EmergencyContact(name: 'Marcus Doe', relation: 'Brother', phone: '+1 (555) 019-9876'),
    ],
  );

  static List<HealthMetric> trackerLogs = [
    // Blood Pressure Systems (BP_SYS)
    HealthMetric(type: 'BP_SYS', value: 122.0, timestamp: DateTime.now().subtract(const Duration(days: 3)), notes: 'Morning check'),
    HealthMetric(type: 'BP_SYS', value: 125.0, timestamp: DateTime.now().subtract(const Duration(days: 2)), notes: 'Feeling a bit stressed'),
    HealthMetric(type: 'BP_SYS', value: 119.0, timestamp: DateTime.now().subtract(const Duration(days: 1)), notes: 'Post-walk reading'),
    HealthMetric(type: 'BP_SYS', value: 118.0, timestamp: DateTime.now(), notes: 'Resting state'),

    // Blood Pressure Diastolic (BP_DIA)
    HealthMetric(type: 'BP_DIA', value: 81.0, timestamp: DateTime.now().subtract(const Duration(days: 3))),
    HealthMetric(type: 'BP_DIA', value: 84.0, timestamp: DateTime.now().subtract(const Duration(days: 2))),
    HealthMetric(type: 'BP_DIA', value: 79.0, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    HealthMetric(type: 'BP_DIA', value: 78.0, timestamp: DateTime.now()),

    // Sugar readings (mg/dL)
    HealthMetric(type: 'SUGAR', value: 104.0, timestamp: DateTime.now().subtract(const Duration(days: 3)), notes: 'Fasting'),
    HealthMetric(type: 'SUGAR', value: 135.0, timestamp: DateTime.now().subtract(const Duration(days: 2)), notes: 'Post-lunch'),
    HealthMetric(type: 'SUGAR', value: 98.0, timestamp: DateTime.now().subtract(const Duration(days: 1)), notes: 'Fasting'),
    HealthMetric(type: 'SUGAR', value: 102.0, timestamp: DateTime.now(), notes: 'Fasting'),

    // Weight readings (kg)
    HealthMetric(type: 'WEIGHT', value: 78.5, timestamp: DateTime.now().subtract(const Duration(days: 15))),
    HealthMetric(type: 'WEIGHT', value: 78.1, timestamp: DateTime.now().subtract(const Duration(days: 7))),
    HealthMetric(type: 'WEIGHT', value: 77.8, timestamp: DateTime.now()),

    // Heart Rate (bpm)
    HealthMetric(type: 'HEART_RATE', value: 72.0, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    HealthMetric(type: 'HEART_RATE', value: 68.0, timestamp: DateTime.now()),

    // SpO2 (%)
    HealthMetric(type: 'SPO2', value: 98.0, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    HealthMetric(type: 'SPO2', value: 99.0, timestamp: DateTime.now()),

    // Temperature (°C)
    HealthMetric(type: 'TEMP', value: 36.6, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    HealthMetric(type: 'TEMP', value: 36.5, timestamp: DateTime.now()),
  ];

  static List<PrescriptionVaultItem> prescriptions = [
    PrescriptionVaultItem(
      id: 'p1',
      doctorName: 'Dr. Sarah Jenkins',
      dateString: 'Jan 15, 2026',
      diagnosis: 'Hypertension and Hyperlipidemia Management',
      notes: 'Continue Lipitor daily. Follow a low-sodium, heart-healthy diet.',
      isAIAnalyzed: true,
      simplifiedMedicines: ['Lipitor (Atorvastatin) - 10mg daily for cholesterol control', 'Lisinopril - 5mg daily for blood pressure control'],
    ),
    PrescriptionVaultItem(
      id: 'p2',
      doctorName: 'Dr. Robert Chen',
      dateString: 'May 04, 2026',
      diagnosis: 'Type 2 Diabetes Mellitus follow up',
      notes: 'Metformin adjusted to twice daily after major meals. Sugar diary to be updated weekly.',
      isAIAnalyzed: true,
      simplifiedMedicines: ['Metformin HCl - 500mg twice daily with meals to stabilize blood sugars'],
    ),
  ];

  static List<ChatMessage> chatHistory = [
    ChatMessage(
      message: 'Hello! I am your MediVault AI Assistant. I can help simplify prescriptions, explain side effects, or check medicine directions. What can I do for you today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];
}
