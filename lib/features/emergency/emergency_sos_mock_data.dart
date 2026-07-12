// ============================================================
// EMERGENCY SOS MOCK DATA
// All data is static/dummy — ready for Firebase + Maps integration.
// Replace MockSOSDatabase fields with real repository/service
// calls when backend is available.
// ============================================================

import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// ENUMS
// ──────────────────────────────────────────────

enum SOSStatus { idle, activating, active, cancelled, resolved }

enum SOSHistoryOutcome { resolved, falseAlarm, cancelled, hospitalized }

enum HospitalType { general, cardiac, trauma, children }

// ──────────────────────────────────────────────
// 1. SOS EMERGENCY CONTACT MODEL
// ──────────────────────────────────────────────

class SOSContact {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final String avatarInitials;
  final Color avatarColor;
  final bool isPrimary;
  final bool isNotified; // whether they've been pinged in current SOS

  const SOSContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.avatarInitials,
    required this.avatarColor,
    this.isPrimary = false,
    this.isNotified = false,
  });

  // Future backend stub
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'relation': relation,
        'phone': phone,
        'isPrimary': isPrimary,
      };
}

// ──────────────────────────────────────────────
// 2. LIVE LOCATION MODEL
// ──────────────────────────────────────────────

class SOSLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String lastUpdated;
  final double accuracyMeters;

  const SOSLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.lastUpdated,
    required this.accuracyMeters,
  });

  String get coordinateString =>
      '${latitude.toStringAsFixed(5)}° N, ${longitude.toStringAsFixed(5)}° E';

  // Future: pass to google_maps_flutter CameraPosition
  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lng': longitude,
        'address': address,
        'lastUpdated': lastUpdated,
        'accuracy': accuracyMeters,
      };
}

// ──────────────────────────────────────────────
// 3. NEARBY HOSPITAL MODEL
// ──────────────────────────────────────────────

class NearbyHospital {
  final String id;
  final String name;
  final String specialty;
  final String address;
  final String phone;
  final double distanceKm;
  final double rating;
  final HospitalType type;
  final bool hasEmergencyUnit;
  final String estimatedArrival; // e.g. "8 min"
  final Color accentColor;

  const NearbyHospital({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.phone,
    required this.distanceKm,
    required this.rating,
    required this.type,
    required this.hasEmergencyUnit,
    required this.estimatedArrival,
    required this.accentColor,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'address': address,
        'phone': phone,
        'distanceKm': distanceKm,
        'rating': rating,
        'hasEmergencyUnit': hasEmergencyUnit,
      };
}

// ──────────────────────────────────────────────
// 4. SOS HISTORY MODEL
// ──────────────────────────────────────────────

class SOSHistoryEvent {
  final String id;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;
  final SOSHistoryOutcome outcome;
  final String location;
  final List<String> contactsNotified;
  final String notes;

  const SOSHistoryEvent({
    required this.id,
    required this.triggeredAt,
    this.resolvedAt,
    required this.outcome,
    required this.location,
    required this.contactsNotified,
    required this.notes,
  });

  Duration? get duration => resolvedAt?.difference(triggeredAt);

  Map<String, dynamic> toMap() => {
        'id': id,
        'triggeredAt': triggeredAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'outcome': outcome.name,
        'location': location,
        'contactsNotified': contactsNotified,
        'notes': notes,
      };
}

// ──────────────────────────────────────────────
// 5. EMERGENCY INSTRUCTION MODEL
// ──────────────────────────────────────────────

class EmergencyInstruction {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> steps;

  const EmergencyInstruction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.steps,
  });
}

// ──────────────────────────────────────────────
// 6. MOCK DATABASE
// ──────────────────────────────────────────────

class MockSOSDatabase {
  MockSOSDatabase._();

  // ── SOS Contacts ──
  static const List<SOSContact> contacts = [
    SOSContact(
      id: 'sc_01',
      name: 'Jane Doe',
      relation: 'Spouse',
      phone: '+1 (555) 019-2834',
      avatarInitials: 'JD',
      avatarColor: Color(0xFF7C3AED),
      isPrimary: true,
    ),
    SOSContact(
      id: 'sc_02',
      name: 'Marcus Doe',
      relation: 'Brother',
      phone: '+1 (555) 019-9876',
      avatarInitials: 'MD',
      avatarColor: Color(0xFF0891B2),
    ),
    SOSContact(
      id: 'sc_03',
      name: 'Dr. Sarah Jenkins',
      relation: 'Cardiologist',
      phone: '+1 (555) 234-5678',
      avatarInitials: 'SJ',
      avatarColor: Color(0xFF2E7D32),
    ),
    SOSContact(
      id: 'sc_04',
      name: 'Emergency Services',
      relation: 'National Emergency',
      phone: '911',
      avatarInitials: '911',
      avatarColor: Color(0xFFD32F2F),
      isPrimary: true,
    ),
  ];

  // ── Live Location (dummy — replace with geolocator package) ──
  static const SOSLocation liveLocation = SOSLocation(
    latitude: 37.42796,
    longitude: -122.08574,
    address: '42 Maple Street, Building 3',
    city: 'Springfield, IL 62701',
    lastUpdated: 'Just now',
    accuracyMeters: 8.5,
  );

  // ── Nearby Hospitals ──
  static const List<NearbyHospital> nearbyHospitals = [
    NearbyHospital(
      id: 'nh_01',
      name: 'Springfield General Hospital',
      specialty: 'Multi-Specialty · Full Emergency Unit',
      address: '120 Medical Center Drive, Springfield',
      phone: '+1 (555) 400-1000',
      distanceKm: 1.2,
      rating: 4.6,
      type: HospitalType.general,
      hasEmergencyUnit: true,
      estimatedArrival: '4 min',
      accentColor: Color(0xFFD32F2F),
    ),
    NearbyHospital(
      id: 'nh_02',
      name: 'Grace Cardiac Clinic',
      specialty: 'Cardiology & Heart Specialist',
      address: 'Suite 402, Grace Medical Tower',
      phone: '+1 (555) 400-2020',
      distanceKm: 2.8,
      rating: 4.9,
      type: HospitalType.cardiac,
      hasEmergencyUnit: false,
      estimatedArrival: '9 min',
      accentColor: Color(0xFFE91E63),
    ),
    NearbyHospital(
      id: 'nh_03',
      name: 'Mercy Trauma Center',
      specialty: 'Level I Trauma Center · ICU',
      address: '88 Mercy Boulevard, Springfield',
      phone: '+1 (555) 400-3030',
      distanceKm: 4.1,
      rating: 4.4,
      type: HospitalType.trauma,
      hasEmergencyUnit: true,
      estimatedArrival: '13 min',
      accentColor: Color(0xFFF57C00),
    ),
  ];

  // ── SOS History ──
  static List<SOSHistoryEvent> sosHistory = [
    SOSHistoryEvent(
      id: 'sh_01',
      triggeredAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      resolvedAt: DateTime.now()
          .subtract(const Duration(days: 3, hours: 1, minutes: 45)),
      outcome: SOSHistoryOutcome.falseAlarm,
      location: '42 Maple Street, Springfield',
      contactsNotified: ['Jane Doe', 'Marcus Doe'],
      notes: 'Accidentally triggered while gardening. Contacts informed.',
    ),
    SOSHistoryEvent(
      id: 'sh_02',
      triggeredAt: DateTime.now().subtract(const Duration(days: 12, hours: 4)),
      resolvedAt:
          DateTime.now().subtract(const Duration(days: 12, hours: 3, minutes: 20)),
      outcome: SOSHistoryOutcome.resolved,
      location: 'Springfield General Hospital Lobby',
      contactsNotified: ['Jane Doe', 'Dr. Sarah Jenkins', 'Emergency Services'],
      notes:
          'Chest pain episode. Ambulance dispatched. Patient stabilized at SGH.',
    ),
    SOSHistoryEvent(
      id: 'sh_03',
      triggeredAt:
          DateTime.now().subtract(const Duration(days: 28, hours: 10)),
      resolvedAt: DateTime.now()
          .subtract(const Duration(days: 28, hours: 9, minutes: 50)),
      outcome: SOSHistoryOutcome.cancelled,
      location: 'Grace Cardiac Clinic, Suite 402',
      contactsNotified: ['Jane Doe'],
      notes:
          'Triggered by mistake before doctor visit. Cancelled within 30 seconds.',
    ),
  ];

  // ── Emergency Instructions ──
  static const List<EmergencyInstruction> instructions = [
    EmergencyInstruction(
      id: 'ei_01',
      title: 'Heart Attack',
      description: 'Suspected cardiac event — act immediately',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFD32F2F),
      steps: [
        'Call 911 immediately — do not wait.',
        'Sit or lie down in a comfortable position.',
        'Loosen any tight clothing around neck or chest.',
        'Chew one aspirin (325mg) if not allergic.',
        'Stay calm and breathe slowly.',
        'Do not eat or drink anything.',
        'Unlock front door for paramedics.',
      ],
    ),
    EmergencyInstruction(
      id: 'ei_02',
      title: 'Severe Hypoglycemia',
      description: 'Blood sugar dangerously low (< 54 mg/dL)',
      icon: Icons.water_drop_outlined,
      color: Color(0xFFF59E0B),
      steps: [
        'If conscious: drink 4oz fruit juice or glucose gel.',
        'Eat 15g fast-acting carbs (3 glucose tablets).',
        'Wait 15 minutes — recheck blood sugar.',
        'If unconscious: do NOT give food or drink by mouth.',
        'Call 911 if no improvement in 15 minutes.',
        'Inject glucagon if available and trained.',
      ],
    ),
    EmergencyInstruction(
      id: 'ei_03',
      title: 'Breathing Difficulty',
      description: 'Severe shortness of breath or asthma attack',
      icon: Icons.air_outlined,
      color: Color(0xFF0891B2),
      steps: [
        'Sit upright — do not lie down.',
        'Use prescribed inhaler if available (2 puffs).',
        'Loosen collar, belt, and any tight garments.',
        'Open windows for fresh air flow.',
        'Call 911 if no relief within 15 minutes.',
        'Stay calm — panic worsens breathing.',
      ],
    ),
    EmergencyInstruction(
      id: 'ei_04',
      title: 'Severe Allergic Reaction',
      description: 'Anaphylaxis — use EpiPen immediately',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFF7C3AED),
      steps: [
        'Inject EpiPen into outer thigh immediately.',
        'Call 911 — anaphylaxis is life-threatening.',
        'Lie flat with legs elevated (unless breathing is hard).',
        'A second EpiPen dose may be given after 5–15 min.',
        'Do not stand or walk — risk of sudden collapse.',
        'Inform responders of substance that caused reaction.',
      ],
    ),
  ];
}
