import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class TtsStatusWidget extends StatefulWidget {
  const TtsStatusWidget({super.key});

  @override
  State<TtsStatusWidget> createState() => _TtsStatusWidgetState();
}

class _TtsStatusWidgetState extends State<TtsStatusWidget> {
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    ttsService.addListener(_onChange);
  }

  @override
  void dispose() {
    ttsService.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  Future<void> _handleTest() async {
    setState(() => _isTesting = true);
    try {
      await ttsService.testSpeaker();
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Color _badgeColor(TtsStatus status) {
    switch (status) {
      case TtsStatus.playing:
      case TtsStatus.generating:
      case TtsStatus.initializing:
        return AppColors.emerald500;
      case TtsStatus.unavailable:
      case TtsStatus.blocked:
      case TtsStatus.failed:
        return AppColors.rose500;
      default:
        return AppColors.slate400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ttsService.status;
    final color = _badgeColor(status);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.volume_up, color: AppColors.indigo500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text('Reminder TTS Speaker Subsystem',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    if (status != TtsStatus.idle)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(status.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  status != TtsStatus.idle && ttsService.spokenText.isNotEmpty
                      ? 'Prompt: "${ttsService.spokenText}"'
                      : 'Audio output routes to the device speaker/headphones.',
                  style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: (status == TtsStatus.playing || _isTesting) ? null : _handleTest,
            icon: const Icon(Icons.volume_up, size: 14),
            label: Text(status == TtsStatus.playing ? 'Speaking...' : 'Test Speaker', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
