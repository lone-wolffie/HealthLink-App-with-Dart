class Medication {
  final int? id;
  final int userId;
  final String name;
  final String dose;
  final List<String> times; 
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medication({
    this.id,
    required this.userId,
    required this.name,
    required this.dose,
    required this.times,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      dose: json['dose'] as String,
      times: (json['times'] is List) ? List<String>.from(json['times']) : [],
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'name': name,
        'dose': dose,
        'times': times,
        'notes': notes,
      };
}
