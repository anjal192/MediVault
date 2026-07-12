class MedicineModel {
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

  MedicineModel({
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
      'isTaken': isTaken,
      'isSkipped': isSkipped,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      frequency: map['frequency'] ?? '',
      beforeFood: map['beforeFood'] ?? false,
      isPrescribed: map['isPrescribed'] ?? false,
      doctorName: map['doctorName'],
      totalQuantity: map['totalQuantity'] ?? 0,
      remainingQuantity: map['remainingQuantity'] ?? 0,
      dailyUsage: map['dailyUsage'] ?? 1,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : DateTime.now(),
      iconName: map['iconName'] ?? 'pill',
      isTaken: map['isTaken'] ?? false,
      isSkipped: map['isSkipped'] ?? false,
    );
  }
}
