import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/analytics_summary.dart';
import '../models/reminder.dart';
import '../models/task_completion.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  AnalyticsSummary? _analytics;
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([apiClient.getAnalytics(), apiClient.getReminders()]);
      if (!mounted) return;
      setState(() {
        _analytics = results[0] as AnalyticsSummary;
        _reminders = results[1] as List<Reminder>;
        _isLoading = false;
      });
    } catch (err) {
      debugPrint('Failed to load history: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = _analytics?.categoryBreakdown ?? [];
    final rows = <MapEntry<Reminder, TaskCompletion>>[];
    for (final r in _reminders) {
      for (final c in r.recentCompletions) {
        rows.add(MapEntry(r, c));
      }
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text('Task Completion History & Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
          Text('Voice confirmation statistics & compliance breakdown', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Routine Category Compliance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                      ),
                      child: Text('${_analytics?.completionRatePercentage.toStringAsFixed(0) ?? 0}% Adherence',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald500)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: categories.isEmpty
                      ? Center(child: Text('No category data yet.', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)))
                      : BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= categories.length) return const SizedBox.shrink();
                                    final name = categories[idx].category;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : '',
                                          style: TextStyle(fontSize: 9, color: context.textSecondaryColor)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              for (int i = 0; i < categories.length; i++)
                                BarChartGroupData(x: i, barRods: [
                                  BarChartRodData(toY: categories[i].completed.toDouble(), color: AppColors.indigo500, width: 10, borderRadius: BorderRadius.circular(4)),
                                  BarChartRodData(toY: categories[i].missed.toDouble(), color: AppColors.rose500, width: 10, borderRadius: BorderRadius.circular(4)),
                                ]),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _LegendDot(color: AppColors.indigo500, label: 'Completed'),
                    SizedBox(width: 16),
                    _LegendDot(color: AppColors.rose500, label: 'Missed'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Spoken Confirmations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No task completions recorded yet.',
                          style: TextStyle(fontSize: 11, color: context.textSecondaryColor, fontStyle: FontStyle.italic)),
                    ),
                  )
                else
                  ...rows.map((entry) {
                    final r = entry.key;
                    final c = entry.value;
                    final isCompleted = c.status == 'completed';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.subtleBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(r.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isCompleted ? AppColors.emerald500 : AppColors.rose500).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: (isCompleted ? AppColors.emerald500 : AppColors.rose500).withValues(alpha: 0.2)),
                                ),
                                child: Text(c.status.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.emerald500 : AppColors.rose500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${r.category} • ${c.createdAt}', style: const TextStyle(fontSize: 10, color: AppColors.indigo500)),
                          const SizedBox(height: 2),
                          Text('"${c.patientSpeechTranscript ?? 'N/A'}"',
                              style: TextStyle(fontSize: 11, color: context.textPrimaryColor, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
      ],
    );
  }
}
