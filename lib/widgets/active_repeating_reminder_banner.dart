import 'package:flutter/material.dart';
import '../services/repeating_reminder_manager.dart';
import '../theme/app_theme.dart';

class ActiveRepeatingReminderBanner extends StatefulWidget {
  const ActiveRepeatingReminderBanner({super.key});

  @override
  State<ActiveRepeatingReminderBanner> createState() => _ActiveRepeatingReminderBannerState();
}

class _ActiveRepeatingReminderBannerState extends State<ActiveRepeatingReminderBanner> {
  @override
  void initState() {
    super.initState();
    repeatingReminderManager.addListener(_onChange);
  }

  @override
  void dispose() {
    repeatingReminderManager.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final status = repeatingReminderManager.status;

    if (status.state == ReminderState.scheduled || (status.reminderId == null && status.state != ReminderState.completed)) {
      return const SizedBox.shrink();
    }

    final isRepeatingActive = status.state == ReminderState.active ||
        status.state == ReminderState.repeating ||
        status.state == ReminderState.listeningForConfirmation;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          if (isRepeatingActive)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF1E1B4B).withValues(alpha: 0.9) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo500.withValues(alpha: context.isDark ? 0.2 : 0.1),
                    blurRadius: 12,
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
                        decoration: BoxDecoration(
                          color: AppColors.indigo500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.access_time, color: AppColors.indigo500, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🔔 REPEATING REMINDER: ${status.title}',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.indigo500)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.amber500.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.amber500.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('Repeating every 5 seconds',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.amber500)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: context.subtleBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: context.borderColor),
                                  ),
                                  child: Text('Next in: ${status.secondsUntilRepeat}s',
                                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.indigo500)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Icon(Icons.mic, size: 14, color: AppColors.emerald500),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text('Listening for voice confirmation... (Say "Task done", "Done", or "Completed")',
                                      style: TextStyle(fontSize: 11, color: AppColors.emerald500, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                            if (status.speechTranscript != null) ...[
                              const SizedBox(height: 4),
                              Text('Recognized speech: "${status.speechTranscript}"',
                                  style: const TextStyle(fontSize: 10, color: AppColors.amber500, fontFamily: 'monospace')),
                            ],
                            if (status.micError != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: AppColors.rose500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text('${status.micError} (Repeating reminder continues every 5s)',
                                        style: const TextStyle(fontSize: 10, color: AppColors.rose500)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => repeatingReminderManager.confirmCompletion('Task done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald500,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Simulate "Task Done"', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => repeatingReminderManager.stopAll(),
                        tooltip: 'Stop repeating timer',
                        style: IconButton.styleFrom(
                          backgroundColor: context.subtleBg,
                          side: BorderSide(color: context.borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(Icons.cancel_outlined, size: 18, color: context.textSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (status.state == ReminderState.completed)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF022C22).withValues(alpha: 0.8) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.emerald500, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ Reminder Completed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.emerald500)),
                        const SizedBox(height: 3),
                        Text(
                          'Completed via voice confirmation (${status.speechTranscript != null ? '"${status.speechTranscript}"' : 'Voice Answer'})',
                          style: TextStyle(fontSize: 11, color: context.textPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => repeatingReminderManager.stopAll(),
                    child: const Text('Dismiss', style: TextStyle(fontSize: 11, color: AppColors.emerald500)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
