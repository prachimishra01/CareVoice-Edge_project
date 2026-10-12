class PatientActivity {
  final int id;
  final int patientId;
  final String activityType; // Walking, Sitting, Standing, Lying, Fall Detected, etc.
  final String status;
  final String? details;
  final String timestamp;
  final String createdAt;

  PatientActivity({
    required this.id,
    required this.patientId,
    required this.activityType,
    required this.status,
    this.details,
    required this.timestamp,
    required this.createdAt,
  });

  factory PatientActivity.fromJson(Map<String, dynamic> json) => PatientActivity(
        id: json['id'] as int,
        patientId: json['patient_id'] as int? ?? 1,
        activityType: json['activity_type'] as String? ?? 'Walking',
        status: json['status'] as String? ?? 'Normal',
        details: json['details'] as String?,
        timestamp: json['timestamp'] as String? ?? 'Just now',
        createdAt: json['created_at'] as String? ?? '',
      );

  static Map<String, dynamic> buildJson({
    int patientId = 1,
    required String activityType,
    String status = 'Normal',
    String? details,
    String? timestamp,
  }) {
    final map = <String, dynamic>{
      'patient_id': patientId,
      'activity_type': activityType,
      'status': status,
    };
    if (details != null) map['details'] = details;
    if (timestamp != null) map['timestamp'] = timestamp;
    return map;
  }
}
