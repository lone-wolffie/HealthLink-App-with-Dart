class Symptoms {
  final int id;
  final int userId;
  final String symptom;
  final String severity;
  final String notes;
  final DateTime dateRecorded;

  // constructor - required fields
  Symptoms({
    required this.id,
    required this.userId,
    required this.symptom,
    required this.severity,
    required this.notes,
    required this.dateRecorded,
  });

  // create symptoms object from JSON data
  factory Symptoms.fromJson(Map<String, dynamic> json) {
    return Symptoms(
      id: json['id'], 
      userId: json['user_id'], 
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
      'user_id': userId,
      'symptom': symptom,
      'severity': severity,
      'notes': notes,
      'created_at': dateRecorded.toIso8601String(),
    };
  }
}