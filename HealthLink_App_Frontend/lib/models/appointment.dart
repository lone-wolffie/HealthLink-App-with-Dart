class Appointment {
  final int? userId;
  final int? clinicId;
  final String appointmentAt;
  final String notes;

  Appointment({
    this.userId,
    this.clinicId,
    required this.appointmentAt,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'clinic_id': clinicId,
      'appointment_date': appointmentAt,
      'notes': notes,
    };
  }
}
