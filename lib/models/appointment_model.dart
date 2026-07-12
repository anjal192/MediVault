class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final bool isUpcoming;

  AppointmentModel({
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

  factory AppointmentModel.fromMap(Map<String, dynamic> map) => AppointmentModel(
    id: map['id'] ?? '',
    doctorName: map['doctorName'] ?? '',
    specialty: map['specialty'] ?? '',
    dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : DateTime.now(),
    location: map['location'] ?? '',
    isUpcoming: map['isUpcoming'] ?? true,
  );
}
