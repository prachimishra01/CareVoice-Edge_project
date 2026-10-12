import 'package:flutter/material.dart';
import '../models/live_status.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class LiveStatusWidget extends StatefulWidget {
  final LiveStatus? status;
  final VoidCallback onRefresh;

  const LiveStatusWidget({super.key, required this.status, required this.onRefresh});

  @override
  State<LiveStatusWidget> createState() => _LiveStatusWidgetState();
}

class _LiveStatusWidgetState extends State<LiveStatusWidget> {
  final _speechController = TextEditingController(text: 'I took my blood pressure medicine');
  bool _isSimulating = false;
  String? _simulationResult;

  @override
  void dispose() {
    _speechController.dispose();
    super.dispose();
  }

  Future<void> _simulate() async {
    final currentId = widget.status?.currentReminder.id ?? 1;
    setState(() {
      _isSimulating = true;
      _simulationResult = null;
    });
    try {
      final res = await apiClient.confirmVoice(currentId, _speechController.text);
      setState(() => _simulationResult = 'Voice Confirmed: ${res['intent']} (${res['status']})');
      widget.onRefresh();
    } catch (err) {
      setState(() => _simulationResult = 'Voice check triggered for current reminder.');
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  Widget _infoTile({required IconData icon, required Color color, required String label, required List<Widget> children, required BuildContext context}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.subtleBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final connected = status?.deviceStatus.raspberryConnected ?? false;

    final activeCard = _infoTile(
      context: context,
      icon: Icons.volume_up,
      color: AppColors.indigo500,
      label: 'Active Voice Prompt',
      children: [
        Text(
          status?.currentReminder.title.isNotEmpty == true ? status!.currentReminder.title : 'No Active Reminders',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Scheduled: ${status?.currentReminder.scheduledTime ?? 'N/A'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
        ),
      ],
    );

    final lastCard = _infoTile(
      context: context,
      icon: Icons.check_circle,
      color: AppColors.emerald500,
      label: 'Last Confirmation',
      children: [
        Text(
          status?.lastConfirmation.status.isNotEmpty == true ? status!.lastConfirmation.status : 'None',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          '"${status?.lastConfirmation.transcript ?? 'No transcript'}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
        ),
      ],
    );

    final nextCard = _infoTile(
      context: context,
      icon: Icons.schedule,
      color: AppColors.amber500,
      label: 'Next Scheduled',
      children: [
        Text(
          status?.nextReminder.title.isNotEmpty == true ? status!.nextReminder.title : 'None',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Time: ${status?.nextReminder.scheduledTime ?? 'N/A'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
        ),
      ],
    );

    return GlassCard(
      borderColor: AppColors.indigo500.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.indigo500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.podcasts, color: AppColors.indigo500, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live Edge Voice Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    Text('Offline Speech Engine & Real-time Task Monitor', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: (connected ? AppColors.emerald500 : AppColors.rose500).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (connected ? AppColors.emerald500 : AppColors.rose500).withValues(alpha: 0.2)),
                ),
                child: Text(connected ? 'Pi Active' : 'Pi Disconnected',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: connected ? AppColors.emerald500 : AppColors.rose500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 520) {
                return Column(
                  children: [
                    activeCard,
                    const SizedBox(height: 10),
                    lastCard,
                    const SizedBox(height: 10),
                    nextCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: activeCard),
                  const SizedBox(width: 8),
                  Expanded(child: lastCard),
                  const SizedBox(width: 8),
                  Expanded(child: nextCard),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(color: context.borderColor, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.mic, size: 16, color: AppColors.indigo500),
              const SizedBox(width: 6),
              Text('Simulate Patient Voice Reply:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _speechController,
            style: TextStyle(fontSize: 12, color: context.textPrimaryColor),
            decoration: const InputDecoration(
              hintText: 'e.g. Done, took medicine',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          if (_simulationResult != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_simulationResult!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.emerald500)),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSimulating ? null : _simulate,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(_isSimulating ? 'Processing Voice...' : 'Trigger Voice Check', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
