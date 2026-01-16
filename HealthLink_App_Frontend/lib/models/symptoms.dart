class Symptoms {
  final int id;
  final String userUuid;
  final String symptom;
  final String severity;
  final String notes;
  final DateTime dateRecorded;

  // constructor - required fields
  Symptoms({
    required this.id,
    required this.userUuid,
    required this.symptom,
    required this.severity,
    required this.notes,
    required this.dateRecorded,
  });

  // create symptoms object from JSON data
  factory Symptoms.fromJson(Map<String, dynamic> json) {
    return Symptoms(
      id: json['id'] as int, 
      userUuid: json['user_uuid'] as String, 
      symptom: json['symptom'], 
      severity: json['severity'], 
      notes: json['notes'] ?? '',
      dateRecorded: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  // convert symptoms object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uuid': userUuid,
      'symptom': symptom,
      'severity': severity,
      'notes': notes,
      'created_at': dateRecorded.toIso8601String(),
    };
  }
}