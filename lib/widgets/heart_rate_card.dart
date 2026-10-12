import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class HeartRateCard extends StatelessWidget {
  final double? heartRate;
  final bool isDemo;
  final VoidCallback? onRefresh;

  const HeartRateCard({
    super.key,
    this.heartRate,
    this.isDemo = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final double displayBpm = heartRate ?? 74.0;
    final bool usingDemoData = isDemo || heartRate == null;

    // Status classification based on standard clinical BPM ranges
    final String rhythmStatus;
    final Color statusColor;
    if (displayBpm < 60) {
      rhythmStatus = 'Bradycardia (Low)';
      statusColor = AppColors.amber500;
    } else if (displayBpm <= 100) {
      rhythmStatus = 'Normal Rhythm';
      statusColor = AppColors.emerald500;
    } else {
      rhythmStatus = 'Elevated (High)';
      statusColor = AppColors.rose500;
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.rose500.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.rose500,
                          AppColors.rose500.withValues(alpha: 0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rose500.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1.08, 1.08),
                        duration: 800.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heart Rate (Vitals)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Continuous pulse monitoring',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Clearly Labelled Demo Data Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: usingDemoData
                      ? AppColors.amber500.withValues(alpha: 0.15)
                      : AppColors.emerald500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: usingDemoData
                        ? AppColors.amber500.withValues(alpha: 0.5)
                        : AppColors.emerald500.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: usingDemoData ? AppColors.amber500 : AppColors.emerald500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      usingDemoData ? 'DEMO DATA' : 'LIVE SENSOR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: usingDemoData ? AppColors.amber400 : AppColors.emerald500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Metric Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayBpm.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimaryColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.rose500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(beats per min)',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      rhythmStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Waveform Graphic / Rhythm Visualizer Bar
          Container(
            height: 38,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.subtleBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      size: 16,
                      color: AppColors.rose500.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      usingDemoData
                          ? 'Demo data · Awaiting live sensor connection'
                          : 'Real-time telemetry stream active',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Range: 60-100',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}
