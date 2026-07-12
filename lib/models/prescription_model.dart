class PrescriptionModel {
  final String id;
  final String doctorName;
  final String dateString;
  final String diagnosis;
  final String notes;
  final bool isAIAnalyzed;
  final List<String> simplifiedMedicines;
  final String? imageUrl;
  final DateTime? consultationDate;
  final String? hospital;
  final int? daysPurchased;
  final DateTime? uploadDate;
  final String? description;

  PrescriptionModel({
    required this.id,
    required this.doctorName,
    required this.dateString,
    required this.diagnosis,
    required this.notes,
    required this.isAIAnalyzed,
    required this.simplifiedMedicines,
    this.imageUrl,
    this.consultationDate,
    this.hospital,
    this.daysPurchased,
    this.uploadDate,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'dateString': dateString,
      'diagnosis': diagnosis,
      'notes': notes,
      'isAIAnalyzed': isAIAnalyzed,
      'simplifiedMedicines': simplifiedMedicines,
      'imageUrl': imageUrl,
      'consultationDate': consultationDate?.toIso8601String(),
      'hospital': hospital,
      'daysPurchased': daysPurchased,
      'uploadDate': uploadDate?.toIso8601String(),
      'description': description,
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'] ?? '',
      doctorName: map['doctorName'] ?? '',
      dateString: map['dateString'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      notes: map['notes'] ?? '',
      isAIAnalyzed: map['isAIAnalyzed'] ?? false,
      simplifiedMedicines: List<String>.from(map['simplifiedMedicines'] ?? []),
      imageUrl: map['imageUrl'],
      consultationDate: map['consultationDate'] != null ? DateTime.parse(map['consultationDate']) : null,
      hospital: map['hospital'],
      daysPurchased: map['daysPurchased'],
      uploadDate: map['uploadDate'] != null ? DateTime.parse(map['uploadDate']) : null,
      description: map['description'],
    );
  }
}

class MedicalRecordModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String recordType; // "report", "scan", "discharge"
  final DateTime uploadDate;
  final String doctor;
  final String hospital;
  final String description;

  MedicalRecordModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.recordType,
    required this.uploadDate,
    required this.doctor,
    required this.hospital,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'recordType': recordType,
      'uploadDate': uploadDate.toIso8601String(),
      'doctor': doctor,
      'hospital': hospital,
      'description': description,
    };
  }

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      recordType: map['recordType'] ?? 'report',
      uploadDate: map['uploadDate'] != null ? DateTime.parse(map['uploadDate']) : DateTime.now(),
      doctor: map['doctor'] ?? '',
      hospital: map['hospital'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
