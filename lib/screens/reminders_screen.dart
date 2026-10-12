import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/api_client.dart';
import '../services/repeating_reminder_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/active_repeating_reminder_banner.dart';
import '../widgets/tts_status_widget.dart';

class RemindersScreen extends StatefulWidget {
  final void Function(Reminder? reminder) onOpenModal;

  const RemindersScreen({super.key, required this.onOpenModal});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final data = await apiClient.getReminders();
      if (!mounted) return;
      setState(() {
        _reminders = data;
        _isLoading = false;
      });
    } catch (err) {
      debugPrint('Failed to load reminders: $err');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('Delete Reminder', style: TextStyle(color: context.textPrimaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${reminder.title}"?',
            style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: context.textSecondaryColor))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.rose500, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await apiClient.deleteReminder(reminder.id);
      _loadReminders();
    }
  }

  Future<void> _handleToggleActive(Reminder reminder) async {
    await apiClient.updateReminder(reminder.id, {'is_active': !reminder.isActive});
    _loadReminders();
  }

  void _handleTestTts(Reminder reminder) {
    apiClient.announceReminder(reminder.id).catchError((err) {
      debugPrint('Backend TTS announce error: $err');
      return null;
    });
    repeatingReminderManager.startRepeatingReminder(reminder.id, reminder.title, reminder.audioPrompt);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient Voice Reminders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    Text('Schedule daily routine prompts', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onOpenModal(null),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('New', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const ActiveRepeatingReminderBanner(),
          const TtsStatusWidget(),
          const SizedBox(height: 14),
          ..._reminders.map((reminder) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                          child: Text(reminder.scheduledTime,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reminder.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                              const SizedBox(height: 2),
                              Text('Repeat: ${reminder.repeatDays} • Max Retries: ${reminder.maxRetries}',
                                  style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.onOpenModal(reminder),
                          icon: Icon(Icons.edit, size: 16, color: context.textSecondaryColor),
                        ),
                        IconButton(
                          onPressed: () => _handleDelete(reminder),
                          icon: Icon(Icons.delete_outline, size: 16, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.subtleBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Text('"${reminder.audioPrompt}"', style: TextStyle(fontSize: 12, color: context.textPrimaryColor)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleToggleActive(reminder),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: reminder.isActive ? AppColors.emerald500 : context.textSecondaryColor,
                            side: BorderSide(color: reminder.isActive ? AppColors.emerald500.withValues(alpha: 0.3) : context.borderColor),
                          ),
                          child: Text(reminder.isActive ? 'Active' : 'Disabled', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        TextButton.icon(
                          onPressed: () => _handleTestTts(reminder),
                          icon: const Icon(Icons.volume_up, size: 14, color: AppColors.indigo500),
                          label: Text('Speak Aloud', style: TextStyle(fontSize: 11, color: context.textPrimaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
