class CategoryStats {
  final String category;
  final int total;
  final int completed;
  final int missed;

  CategoryStats({
    required this.category,
    required this.total,
    required this.completed,
    required this.missed,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) => CategoryStats(
        category: json['category'] as String,
        total: json['total'] as int,
        completed: json['completed'] as int,
        missed: json['missed'] as int,
      );
}

class AnalyticsSummary {
  final int totalReminders;
  final double completionRatePercentage;
  final int totalCompletedTasks;
  final int totalMissedTasks;
  final int totalEmergencyEvents;
  final int activeEmergencies;
  final double averageResponseTimeSeconds;
  final List<CategoryStats> categoryBreakdown;

  AnalyticsSummary({
    required this.totalReminders,
    required this.completionRatePercentage,
    required this.totalCompletedTasks,
    required this.totalMissedTasks,
    required this.totalEmergencyEvents,
    required this.activeEmergencies,
    required this.averageResponseTimeSeconds,
    required this.categoryBreakdown,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) => AnalyticsSummary(
        totalReminders: json['total_reminders'] as int? ?? 0,
        completionRatePercentage: (json['completion_rate_percentage'] as num?)?.toDouble() ?? 0,
        totalCompletedTasks: json['total_completed_tasks'] as int? ?? 0,
        totalMissedTasks: json['total_missed_tasks'] as int? ?? 0,
        totalEmergencyEvents: json['total_emergency_events'] as int? ?? 0,
        activeEmergencies: json['active_emergencies'] as int? ?? 0,
        averageResponseTimeSeconds: (json['average_response_time_seconds'] as num?)?.toDouble() ?? 0,
        categoryBreakdown: (json['category_breakdown'] as List<dynamic>?)
                ?.map((e) => CategoryStats.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
