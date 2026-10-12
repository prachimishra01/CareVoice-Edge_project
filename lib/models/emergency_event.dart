class EmergencyEvent {
  final int id;
  final int? patientId;
  final String triggerSource;
  final String status; // active | resolved | acknowledged
  final String? speechTranscript;
  final bool notificationSent;
  final bool phoneCallInitiated;
  final String? resolvedAt;
  final String? notes;
  final String createdAt;

  EmergencyEvent({
    required this.id,
    this.patientId,
    required this.triggerSource,
    required this.status,
    this.speechTranscript,
    required this.notificationSent,
    required this.phoneCallInitiated,
    this.resolvedAt,
    this.notes,
    required this.createdAt,
  });

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) => EmergencyEvent(
        id: json['id'] as int,
        patientId: json['patient_id'] as int?,
        triggerSource: (json['trigger_source'] ?? json['alert_type'] ?? 'Emergency') as String,
        status: (json['status'] as String?) ?? 'active',
        speechTranscript: (json['speech_transcript'] ?? json['message']) as String?,
        notificationSent: json['notification_sent'] as bool? ?? false,
        phoneCallInitiated: json['phone_call_initiated'] as bool? ?? false,
        resolvedAt: json['resolved_at'] as String?,
        notes: (json['notes'] ?? json['details']) as String?,
        createdAt: (json['created_at'] ?? json['timestamp'] ?? '') as String,
      );

  String get alertType => triggerSource;
  String? get message => speechTranscript;
  String get timestamp => createdAt;
}

