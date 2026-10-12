import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analytics_summary.dart';
import '../models/emergency_event.dart';
import '../models/live_status.dart';
import '../models/patient.dart';
import '../models/patient_activity.dart';
import '../models/health_data.dart';
import '../widgets/heart_rate_card.dart';
import '../models/reminder.dart';
import '../services/api_client.dart';
import '../services/emergency_manager.dart';
import '../services/repeating_reminder_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/active_repeating_reminder_banner.dart';
import '../widgets/emergency_alert_banner.dart';
import '../widgets/emergency_countdown_overlay.dart';
import '../widgets/glass_card.dart';
import '../widgets/live_status_widget.dart';
import '../widgets/patient_camera_monitor.dart';
import '../widgets/patient_summary_widget.dart';
import '../widgets/recent_patient_activity.dart';
import '../widgets/stat_card.dart';
import '../widgets/tts_status_widget.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenReminderModal;
  final void Function(String tab)? onNavigateTab;

  const DashboardScreen({super.key, required this.onOpenReminderModal, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AnalyticsSummary? _analytics;
  LiveStatus? _liveStatus;
  List<EmergencyEvent> _emergencies = [];
  List<Reminder> _reminders = [];
  List<PatientActivityEntry> _activities = [];
  Patient? _patient;
  HealthData? _healthData;
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        apiClient.getAnalytics(),
        apiClient.getLiveStatus(),
        apiClient.getEmergencies(),
        apiClient.getReminders(),
        apiClient.getPatients(),
        apiClient.getRecentActivities(limit: 6),
        apiClient.getLatestHealthData(),
      ]);
      if (!mounted) return;
      setState(() {
        _analytics = results[0] as AnalyticsSummary;
        _liveStatus = results[1] as LiveStatus;
        _emergencies = results[2] as List<EmergencyEvent>;
        _reminders = results[3] as List<Reminder>;
        final patients = results[4] as List<Patient>;
        if (patients.isNotEmpty) _patient = patients.first;
        final acts = results[5] as List<PatientActivity>;
        if (acts.isNotEmpty) {
          _activities = acts.map((a) => PatientActivityEntry.fromModel(a)).toList();
        }
        final health = results[6] as HealthData?;
        if (health != null) {
          _healthData = health;
        }
        _isLoading = false;
      });
    } catch (err) {
      debugPrint('Failed to load dashboard data: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResolveEmergency(int id) async {
    await apiClient.resolveEmergency(id, notes: 'Resolved by Caretaker from Dashboard');
    _fetchData();
  }

  Future<void> _handleTriggerManualSos() async {
    await apiClient.voiceSos('Manual SOS test triggered by Caretaker');
    _fetchData();
  }

  Future<void> _handleAnnounceNow(int reminderId) async {
    final rem = _reminders.where((r) => r.id == reminderId).toList();
    final title = rem.isNotEmpty ? rem.first.title : 'Medicine Reminder';
    final prompt = rem.isNotEmpty ? rem.first.audioPrompt : 'Please take your scheduled medicine.';

    apiClient.announceReminder(reminderId).catchError((err) {
      debugPrint('Backend TTS announce error: $err');
      return null;
    });

    repeatingReminderManager.startRepeatingReminder(reminderId, title, prompt);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetchData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              EmergencyAlertBanner(
                emergencies: _emergencies,
                onResolve: _handleResolveEmergency,
                onTriggerManualSos: _handleTriggerManualSos,
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              const ActiveRepeatingReminderBanner(),
              const SizedBox(height: 10),
              _SectionHeader(
                title: 'Health Overview',
                subtitle: 'Real-time patient statistics',
                onAction: () {},
              ),
              const SizedBox(height: 12),
              HeartRateCard(
                heartRate: _healthData?.heartRate,
                isDemo: _healthData?.heartRate == null,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  StatCard(
                    title: 'Compliance',
                    value: '${_analytics?.completionRatePercentage.toStringAsFixed(0) ?? 100}%',
                    subtitle: '${_analytics?.totalCompletedTasks ?? 0} tasks done',
                    icon: Icons.task_alt_rounded,
                    trend: 'High',
                    badgeColor: BadgeColor.emerald,
                  ),
                  StatCard(
                    title: 'Active Reminders',
                    value: '${_analytics?.totalReminders ?? 0}',
                    subtitle: 'Scheduled voices',
                    icon: Icons.alarm_rounded,
                    badgeColor: BadgeColor.indigo,
                  ),
                  StatCard(
                    title: 'Alerts',
                    value: '${_analytics?.totalEmergencyEvents ?? 0}',
                    subtitle: '${_analytics?.activeEmergencies ?? 0} pending',
                    icon: Icons.emergency_rounded,
                    badgeColor: (_analytics?.activeEmergencies ?? 0) > 0 ? BadgeColor.rose : BadgeColor.emerald,
                  ),
                  StatCard(
                    title: 'Response',
                    value: '${_analytics?.averageResponseTimeSeconds.toStringAsFixed(1) ?? 8.5}s',
                    subtitle: 'Avg response time',
                    icon: Icons.bolt_rounded,
                    badgeColor: BadgeColor.amber,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionHeader(title: 'Live Monitor', subtitle: 'Patient optical feed'),
                  ElevatedButton.icon(
                    onPressed: () => emergencyManager.triggerFallDetection(_patient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rose500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.emergency_share, size: 14),
                    label: const Text('TEST FALL DETECTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PatientCameraMonitor(
                onFallDetected: () => emergencyManager.triggerFallDetection(_patient),
              ).animate().scale(delay: 200.ms),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Patient Profile', subtitle: 'Basic information'),
              const SizedBox(height: 12),
              PatientSummaryWidget(
                patient: _patient,
                onEditProfile: () => widget.onNavigateTab?.call('patient'),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Daily Schedule', subtitle: 'Healthcare routine'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: _reminders.isEmpty
                    ? [Text('No reminders scheduled', style: TextStyle(color: context.textSecondaryColor))]
                    : _reminders.map((reminder) => _ReminderTile(
                        reminder: reminder,
                        onAnnounce: () => _handleAnnounceNow(reminder.id),
                      )).toList(),
                ),
              ).animate().slideY(begin: 0.2, end: 0, delay: 600.ms),
              const SizedBox(height: 24),
              RecentPatientActivity(activities: _activities.isNotEmpty ? _activities : PatientActivityEntry.defaultActivities),
              const SizedBox(height: 16),
              const TtsStatusWidget(),
              const SizedBox(height: 16),
              LiveStatusWidget(status: _liveStatus, onRefresh: _fetchData),
            ],
          ),
        ),
        const EmergencyCountdownOverlay(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, required this.subtitle, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
          ],
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: const Text('See All', style: TextStyle(color: AppColors.indigo500, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onAnnounce;

  const _ReminderTile({required this.reminder, required this.onAnnounce});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.subtleBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              reminder.scheduledTime,
              style: const TextStyle(color: AppColors.indigo500, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                Text(reminder.audioPrompt, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
              ],
            ),
          ),
          IconButton(
            onPressed: onAnnounce,
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.indigo500, size: 20),
          ),
        ],
      ),
    );
  }
}
