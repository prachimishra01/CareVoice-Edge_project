class TaskCompletion {
  final int id;
  final int reminderId;
  final String status; // completed | missed | retry_pending
  final String? completedAt;
  final String? patientSpeechTranscript;
  final double? responseTimeSeconds;
  final int attemptCount;
  final String? notes;
  final String createdAt;

  TaskCompletion({
    required this.id,
    required this.reminderId,
    required this.status,
    this.completedAt,
    this.patientSpeechTranscript,
    this.responseTimeSeconds,
    required this.attemptCount,
    this.notes,
    required this.createdAt,
  });

  factory TaskCompletion.fromJson(Map<String, dynamic> json) => TaskCompletion(
        id: json['id'] as int,
        reminderId: json['reminder_id'] as int,
        status: json['status'] as String,
        completedAt: json['completed_at'] as String?,
        patientSpeechTranscript: json['patient_speech_transcript'] as String?,
        responseTimeSeconds: (json['response_time_seconds'] as num?)?.toDouble(),
        attemptCount: json['attempt_count'] as int? ?? 0,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}
