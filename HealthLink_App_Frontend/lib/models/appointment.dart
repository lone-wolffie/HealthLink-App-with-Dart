class Appointment {
  final String userUuid;
  final int clinicId;
  final String appointmentAt;
  final String notes;

  Appointment({
    required this.userUuid,
    required this.clinicId,
    required this.appointmentAt,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_uuid': userUuid,
      'clinic_id': clinicId,
      'appointment_at': appointmentAt,
      'notes': notes,
    };
  }
}
