// ============================================================
// CAREGIVER MOCK DATA
// All data is static/dummy — ready for Firebase integration.
// Replace MockCaregiverDatabase fields with real repository
// calls when backend is available.
// ============================================================

import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// ENUMS
// ──────────────────────────────────────────────

enum MedStatus { taken, pending, missed }

enum HealthStatusLevel { stable, warning, critical }

enum CaregiverNotifType {
  medicineTaken,
  medicineMissed,
  lowStock,
  appointmentReminder,
  voiceReminder,
  sosAlert,
}

// ──────────────────────────────────────────────
// 1. PATIENT MODEL
// ──────────────────────────────────────────────

class CaregiverPatient {
  final String id;
  final String name;
  final int age;
  final String bloodGroup;
  final String medicalCondition;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final HealthStatusLevel healthStatus;
  final String healthStatusNote;

  const CaregiverPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.medicalCondition,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    required this.healthStatus,
    required this.healthStatusNote,
  });

  // Future Firebase integration stub
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'bloodGroup': bloodGroup,
        'medicalCondition': medicalCondition,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'emergencyContactRelation': emergencyContactRelation,
        'healthStatus': healthStatus.name,
        'healthStatusNote': healthStatusNote,
      };
}

// ──────────────────────────────────────────────
// 2. CAREGIVER MEDICINE MODEL
// ──────────────────────────────────────────────

class CaregiverMedicine {
  final String id;
  final String name;
  final String iconName; // 'capsule', 'tablet', 'syrup', 'pill'
  final String time;
  final String dosage;
  final MedStatus status;
  final Color accentColor;

  const CaregiverMedicine({
    required this.id,
    required this.name,
    required this.iconName,
    required this.time,
    required this.dosage,
    required this.status,
    required this.accentColor,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'time': time,
        'dosage': dosage,
        'status': status.name,
      };
}

// ──────────────────────────────────────────────
// 3. DAILY ADHERENCE (for 7-day calendar/graph)
// ──────────────────────────────────────────────

class DailyAdherence {
  final DateTime date;
  final int totalMeds;
  final int takenMeds;

  const DailyAdherence({
    required this.date,
    required this.totalMeds,
    required this.takenMeds,
  });

  double get percentage =>
      totalMeds == 0 ? 0.0 : (takenMeds / totalMeds).clamp(0.0, 1.0);

  bool get isPerfect => takenMeds == totalMeds;
  bool get isMissed => takenMeds == 0;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'totalMeds': totalMeds,
        'takenMeds': takenMeds,
      };
}

// ──────────────────────────────────────────────
// 4. CAREGIVER NOTIFICATION MODEL
// ──────────────────────────────────────────────

class CaregiverNotification {
  final String id;
  final CaregiverNotifType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  const CaregiverNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };
}

// ──────────────────────────────────────────────
// 5. AI HEALTH SUMMARY MODEL
// ──────────────────────────────────────────────

class AIHealthSummary {
  final int healthScore; // 0-100
  final double medicineAdherence; // 0.0 - 1.0
  final String mostFrequentlyMissedMedicine;
  final String recommendation;
  final String generatedAt;

  const AIHealthSummary({
    required this.healthScore,
    required this.medicineAdherence,
    required this.mostFrequentlyMissedMedicine,
    required this.recommendation,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() => {
        'healthScore': healthScore,
        'medicineAdherence': medicineAdherence,
        'mostFrequentlyMissedMedicine': mostFrequentlyMissedMedicine,
        'recommendation': recommendation,
        'generatedAt': generatedAt,
      };
}

// ──────────────────────────────────────────────
// 6. EMERGENCY STATUS MODEL
// ──────────────────────────────────────────────

class EmergencyStatus {
  final bool isSOS;
  final String statusLabel;
  final String lastChecked;
  final String patientLocation; // dummy text

  const EmergencyStatus({
    required this.isSOS,
    required this.statusLabel,
    required this.lastChecked,
    required this.patientLocation,
  });
}

// ──────────────────────────────────────────────
// 7. MOCK DATABASE (Replace with real service)
// ──────────────────────────────────────────────

class MockCaregiverDatabase {
  MockCaregiverDatabase._();

  // ── Patient ──
  static const CaregiverPatient patient = CaregiverPatient(
    id: 'cp_001',
    name: 'John Doe',
    age: 68,
    bloodGroup: 'O−',
    medicalCondition: 'Type 2 Diabetes & Hypertension',
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '+1 (555) 019-2834',
    emergencyContactRelation: 'Spouse',
    healthStatus: HealthStatusLevel.stable,
    healthStatusNote: 'Vitals are within normal range. Last check: Today 08:30 AM',
  );

  // ── Today's Medicines ──
  static const List<CaregiverMedicine> todayMedicines = [
    CaregiverMedicine(
      id: 'cm_01',
      name: 'Atorvastatin (Lipitor)',
      iconName: 'capsule',
      time: '08:00 AM',
      dosage: '10 mg',
      status: MedStatus.taken,
      accentColor: Color(0xFF2E7D32),
    ),
    CaregiverMedicine(
      id: 'cm_02',
      name: 'Metformin HCl',
      iconName: 'tablet',
      time: '01:00 PM',
      dosage: '500 mg',
      status: MedStatus.pending,
      accentColor: Color(0xFFF59E0B),
    ),
    CaregiverMedicine(
      id: 'cm_03',
      name: 'Amoxicillin',
      iconName: 'capsule',
      time: '09:00 AM',
      dosage: '250 mg',
      status: MedStatus.missed,
      accentColor: Color(0xFFD32F2F),
    ),
    CaregiverMedicine(
      id: 'cm_04',
      name: 'Lisinopril',
      iconName: 'tablet',
      time: '08:00 AM',
      dosage: '5 mg',
      status: MedStatus.taken,
      accentColor: Color(0xFF2E7D32),
    ),
    CaregiverMedicine(
      id: 'cm_05',
      name: 'Multivitamin',
      iconName: 'pill',
      time: '07:00 AM',
      dosage: '1 Capsule',
      status: MedStatus.pending,
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  // ── Weekly Adherence (last 7 days, oldest first) ──
  static List<DailyAdherence> weeklyAdherence = [
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 6)),
      totalMeds: 5,
      takenMeds: 5,
    ),
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 5)),
      totalMeds: 5,
      takenMeds: 4,
    ),
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 4)),
      totalMeds: 5,
      takenMeds: 3,
    ),
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 3)),
      totalMeds: 5,
      takenMeds: 5,
    ),
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 2)),
      totalMeds: 5,
      takenMeds: 2,
    ),
    DailyAdherence(
      date: DateTime.now().subtract(const Duration(days: 1)),
      totalMeds: 5,
      takenMeds: 4,
    ),
    DailyAdherence(
      date: DateTime.now(),
      totalMeds: 5,
      takenMeds: 2, // today is in progress
    ),
  ];

  // ── Notifications ──
  static List<CaregiverNotification> notifications = [
    CaregiverNotification(
      id: 'cn_01',
      type: CaregiverNotifType.medicineTaken,
      title: 'Medicine Taken ✅',
      body: 'John took Atorvastatin (10 mg) at 08:03 AM — on time.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 3)),
    ),
    CaregiverNotification(
      id: 'cn_02',
      type: CaregiverNotifType.medicineMissed,
      title: 'Medicine Missed ❌',
      body: 'Amoxicillin (09:00 AM dose) was not taken. 3rd missed dose this week.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    CaregiverNotification(
      id: 'cn_03',
      type: CaregiverNotifType.lowStock,
      title: 'Low Stock Warning ⚠️',
      body: 'Metformin HCl has only 4 tablets remaining — refill needed within 2 days.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    CaregiverNotification(
      id: 'cn_04',
      type: CaregiverNotifType.appointmentReminder,
      title: 'Appointment Reminder 📅',
      body: 'Dr. Sarah Jenkins — Cardiology visit in 2 days at Grace Cardiac Clinic.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    CaregiverNotification(
      id: 'cn_05',
      type: CaregiverNotifType.voiceReminder,
      title: 'Voice Reminder Sent 🔔',
      body: 'Voice reminder for Metformin (01:00 PM) was successfully delivered.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    CaregiverNotification(
      id: 'cn_06',
      type: CaregiverNotifType.sosAlert,
      title: 'SOS Alert Cleared 🚨',
      body: 'Earlier SOS alert has been resolved. Patient confirmed safe at 09:45 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
    ),
  ];

  // ── AI Health Summary ──
  static const AIHealthSummary aiSummary = AIHealthSummary(
    healthScore: 74,
    medicineAdherence: 0.71,
    mostFrequentlyMissedMedicine: 'Amoxicillin (09:00 AM)',
    recommendation:
        'John has missed his morning antibiotic 3 times this week. '
        'Consider setting an additional voice reminder at 08:45 AM. '
        'Blood sugar levels appear stable based on medicine compliance.',
    generatedAt: 'Today, 09:00 AM',
  );

  // ── Emergency Status ──
  static const EmergencyStatus emergencyStatus = EmergencyStatus(
    isSOS: false,
    statusLabel: 'Patient is Safe',
    lastChecked: 'Today, 09:45 AM',
    patientLocation: '42 Maple Street, Springfield — Home',
  );
}
