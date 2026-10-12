class Patient {
  final int id;
  final String fullName;
  final int age;
  final String? roomNumber;
  final String? medicalConditions;
  final String? emergencyContact;
  final String? notes;
  final String? summary;
  final int? caretakerId;
  final String createdAt;
  final String updatedAt;

  Patient({
    required this.id,
    required this.fullName,
    required this.age,
    this.roomNumber,
    this.medicalConditions,
    this.emergencyContact,
    this.notes,
    this.summary,
    this.caretakerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as int,
        fullName: json['full_name'] as String,
        age: json['age'] as int,
        roomNumber: json['room_number'] as String?,
        medicalConditions: json['medical_conditions'] as String?,
        emergencyContact: json['emergency_contact'] as String?,
        notes: json['notes'] as String?,
        summary: json['summary'] as String?,
        caretakerId: json['caretaker_id'] as int?,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  Map<String, dynamic> toUpdateJson({
    String? fullName,
    int? age,
    String? roomNumber,
    String? medicalConditions,
    String? emergencyContact,
    String? notes,
    String? summary,
  }) {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    if (age != null) map['age'] = age;
    if (roomNumber != null) map['room_number'] = roomNumber;
    if (medicalConditions != null) map['medical_conditions'] = medicalConditions;
    if (emergencyContact != null) map['emergency_contact'] = emergencyContact;
    if (notes != null) map['notes'] = notes;
    if (summary != null) map['summary'] = summary;
    return map;
  }
}
