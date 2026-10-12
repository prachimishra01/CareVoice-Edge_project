import 'package:flutter/material.dart';
import '../models/emergency_event.dart';
import '../theme/app_theme.dart';

class EmergencyAlertBanner extends StatelessWidget {
  final List<EmergencyEvent> emergencies;
  final void Function(int id) onResolve;
  final VoidCallback onTriggerManualSos;

  const EmergencyAlertBanner({
    super.key,
    required this.emergencies,
    required this.onResolve,
    required this.onTriggerManualSos,
  });

  @override
  Widget build(BuildContext context) {
    final active = emergencies.where((e) => e.status == 'active').toList();

    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.subtleBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.emerald500),
                const SizedBox(width: 8),
                Text('No Active Emergency Alerts',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimaryColor)),
              ],
            ),
            TextButton.icon(
              onPressed: onTriggerManualSos,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: AppColors.rose500.withValues(alpha: 0.1),
                foregroundColor: AppColors.rose500,
                side: BorderSide(color: AppColors.rose500.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.phone_in_talk, size: 14),
              label: const Text('Emergency Call / SOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: active
          .map((emergency) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C0519).withValues(alpha: context.isDark ? 0.85 : 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.rose500.withValues(alpha: 0.6)),
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
                              color: AppColors.rose500.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.rose500.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppColors.rose400, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    const Text('VOICE EMERGENCY ALERT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.rose500,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(emergency.speechTranscript ?? 'Emergency trigger event registered.',
                                    style: const TextStyle(fontSize: 12, color: AppColors.slate200, fontStyle: FontStyle.italic)),
                                const SizedBox(height: 4),
                                Text('Triggered at: ${emergency.createdAt}', style: const TextStyle(fontSize: 10, color: AppColors.rose300)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => onResolve(emergency.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald500,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Resolve Emergency Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
