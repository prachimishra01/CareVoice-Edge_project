class HealthData {
  final int id;
  final int patientId;
  final double? heartRate;
  final double? spo2;
  final double? temperature;
  final int? systolicBp;
  final int? diastolicBp;
  final String status;
  final String timestamp;
  final String createdAt;

  HealthData({
    required this.id,
    required this.patientId,
    this.heartRate,
    this.spo2,
    this.temperature,
    this.systolicBp,
    this.diastolicBp,
    required this.status,
    required this.timestamp,
    required this.createdAt,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
        id: json['id'] as int,
        patientId: json['patient_id'] as int? ?? 1,
        heartRate: (json['heart_rate'] as num?)?.toDouble(),
        spo2: (json['spo2'] as num?)?.toDouble(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        systolicBp: json['systolic_bp'] as int?,
        diastolicBp: json['diastolic_bp'] as int?,
        status: json['status'] as String? ?? 'Normal',
        timestamp: json['timestamp'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );

  static Map<String, dynamic> buildJson({
    int patientId = 1,
    double? heartRate,
    double? spo2,
    double? temperature,
    int? systolicBp,
    int? diastolicBp,
    String status = 'Normal',
    String? timestamp,
  }) {
    final map = <String, dynamic>{
      'patient_id': patientId,
      'status': status,
    };
    if (heartRate != null) map['heart_rate'] = heartRate;
    if (spo2 != null) map['spo2'] = spo2;
    if (temperature != null) map['temperature'] = temperature;
    if (systolicBp != null) map['systolic_bp'] = systolicBp;
    if (diastolicBp != null) map['diastolic_bp'] = diastolicBp;
    if (timestamp != null) map['timestamp'] = timestamp;
    return map;
  }
}
