import 'task_completion.dart';

class Reminder {
  final int id;
  final int patientId;
  final String title;
  final String category; // medicine | exercise | hydration | vitals | general
  final String scheduledTime;
  final String repeatDays;
  final bool isActive;
  final String audioPrompt;
  final int maxRetries;
  final int retryIntervalMinutes;
  final List<TaskCompletion> recentCompletions;
  final String createdAt;
  final String updatedAt;

  Reminder({
    required this.id,
    required this.patientId,
    required this.title,
    required this.category,
    required this.scheduledTime,
    required this.repeatDays,
    required this.isActive,
    required this.audioPrompt,
    required this.maxRetries,
    required this.retryIntervalMinutes,
    this.recentCompletions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as int,
        patientId: json['patient_id'] as int,
        title: json['title'] as String,
        category: json['category'] as String,
        scheduledTime: json['scheduled_time'] as String,
        repeatDays: json['repeat_days'] as String,
        isActive: json['is_active'] as bool,
        audioPrompt: json['audio_prompt'] as String,
        maxRetries: json['max_retries'] as int? ?? 3,
        retryIntervalMinutes: json['retry_interval_minutes'] as int? ?? 5,
        recentCompletions: (json['recent_completions'] as List<dynamic>?)
                ?.map((e) => TaskCompletion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  static Map<String, dynamic> buildJson({
    required int patientId,
    required String title,
    required String category,
    required String scheduledTime,
    required String repeatDays,
    required String audioPrompt,
    required int maxRetries,
    bool? isActive,
  }) {
    final map = <String, dynamic>{
      'patient_id': patientId,
      'title': title,
      'category': category,
      'scheduled_time': scheduledTime,
      'repeat_days': repeatDays,
      'audio_prompt': audioPrompt,
      'max_retries': maxRetries,
    };
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
