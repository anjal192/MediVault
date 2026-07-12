class TrackerModel {
  final String id;
  final String type; // "BP_SYS", "BP_DIA", "SUGAR", "WEIGHT", "HEART_RATE", "SPO2", "TEMP"
  final double value;
  final DateTime timestamp;
  final String notes;

  TrackerModel({
    required this.id,
    required this.type,
    required this.value,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory TrackerModel.fromMap(Map<String, dynamic> map) {
    return TrackerModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }
}
