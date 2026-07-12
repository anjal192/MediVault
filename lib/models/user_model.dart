class UserModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String bloodGroup;
  final double height; // in cm
  final double weight; // in kg
  final double bmi;
  final bool undergoingTreatment;
  final String diagnosedDisease;
  final int diagnosedYear;
  final String currentTreatment;
  final String consultingDoctor;
  final String hospital;
  final List<String> foodAllergies;
  final List<String> medicineAllergies;
  final List<String> familyHistory;
  final List<String> previousTreatments;
  final List<String> pastSurgeries;
  final List<String> vaccinations;
  final List<EmergencyContactModel> emergencyContacts;
  final int profileCompletion;
  final double healthScore;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age = 0,
    this.gender = "Not Specified",
    this.bloodGroup = "O+",
    this.height = 0.0,
    this.weight = 0.0,
    double? bmi,
    this.undergoingTreatment = false,
    this.diagnosedDisease = "",
    this.diagnosedYear = 0,
    this.currentTreatment = "",
    this.consultingDoctor = "",
    this.hospital = "",
    this.foodAllergies = const [],
    this.medicineAllergies = const [],
    this.familyHistory = const [],
    this.previousTreatments = const [],
    this.pastSurgeries = const [],
    this.vaccinations = const [],
    this.emergencyContacts = const [],
    this.profileCompletion = 50,
    this.healthScore = 90.0,
  }) : bmi = bmi ?? _calculateBmi(height, weight);

  static double _calculateBmi(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    double heightM = heightCm / 100.0;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'undergoingTreatment': undergoingTreatment,
      'diagnosedDisease': diagnosedDisease,
      'diagnosedYear': diagnosedYear,
      'currentTreatment': currentTreatment,
      'consultingDoctor': consultingDoctor,
      'hospital': hospital,
      'foodAllergies': foodAllergies,
      'medicineAllergies': medicineAllergies,
      'familyHistory': familyHistory,
      'previousTreatments': previousTreatments,
      'pastSurgeries': pastSurgeries,
      'vaccinations': vaccinations,
      'emergencyContacts': emergencyContacts.map((c) => c.toMap()).toList(),
      'profileCompletion': profileCompletion,
      'healthScore': healthScore,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Not Specified',
      bloodGroup: map['bloodGroup'] ?? 'O+',
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      bmi: (map['bmi'] as num?)?.toDouble(),
      undergoingTreatment: map['undergoingTreatment'] ?? false,
      diagnosedDisease: map['diagnosedDisease'] ?? '',
      diagnosedYear: map['diagnosedYear'] ?? 0,
      currentTreatment: map['currentTreatment'] ?? '',
      consultingDoctor: map['consultingDoctor'] ?? '',
      hospital: map['hospital'] ?? '',
      foodAllergies: List<String>.from(map['foodAllergies'] ?? []),
      medicineAllergies: List<String>.from(map['medicineAllergies'] ?? []),
      familyHistory: List<String>.from(map['familyHistory'] ?? []),
      previousTreatments: List<String>.from(map['previousTreatments'] ?? []),
      pastSurgeries: List<String>.from(map['pastSurgeries'] ?? []),
      vaccinations: List<String>.from(map['vaccinations'] ?? []),
      emergencyContacts: (map['emergencyContacts'] as List?)
              ?.map((c) => EmergencyContactModel.fromMap(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
      profileCompletion: map['profileCompletion'] ?? 50,
      healthScore: (map['healthScore'] as num?)?.toDouble() ?? 90.0,
    );
  }
}

class EmergencyContactModel {
  final String name;
  final String relation;
  final String phone;

  EmergencyContactModel({
    required this.name,
    required this.relation,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
    };
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
