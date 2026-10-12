import 'package:flutter/material.dart';
import '../services/emergency_manager.dart';
import '../theme/app_theme.dart';

class EmergencyCountdownOverlay extends StatelessWidget {
  const EmergencyCountdownOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmergencyState>(
      stream: emergencyManager.stateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.isActive) {
          return const SizedBox.shrink();
        }

        final state = snapshot.data!;

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 80, color: AppColors.rose500),
                  const SizedBox(height: 24),
                  const Text(
                    '🚨 POSSIBLE FALL DETECTED',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you okay?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate300,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: state.secondsRemaining / 10,
                          strokeWidth: 8,
                          color: AppColors.rose500,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Text(
                        '${state.secondsRemaining}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => emergencyManager.cancelEmergency(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald500,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "I'M OK",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => emergencyManager.startImmediateCommunication(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rose500,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "CALL NOW",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Automatic emergency alert will be sent when timer reaches zero.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.slate400),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
