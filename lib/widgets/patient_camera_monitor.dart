import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

const _cameraStorageKey = 'carevoice_camera_enabled';

class PatientCameraMonitor extends StatefulWidget {
  final VoidCallback? onFallDetected;
  const PatientCameraMonitor({super.key, this.onFallDetected});

  @override
  State<PatientCameraMonitor> createState() => _PatientCameraMonitorState();
}

class _PatientCameraMonitorState extends State<PatientCameraMonitor> {
  CameraController? _controller;
  bool _isStreaming = false;
  bool _privacyMode = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _restorePreviousState();
  }

  Future<void> _restorePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_cameraStorageKey) == true) {
      await _startCamera();
    }
  }

  Future<void> _startCamera() async {
    setState(() => _errorMsg = null);
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        setState(() => _errorMsg = 'Camera permission denied. Please enable it in app settings.');
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMsg = 'Device camera API is not supported by this device.');
        return;
      }

      final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isStreaming = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cameraStorageKey, true);
    } catch (err) {
      setState(() {
        _errorMsg = 'Unable to access device camera. Please check permissions. ($err)';
        _isStreaming = false;
      });
    }
  }

  Future<void> _stopCamera() async {
    await _controller?.dispose();
    _controller = null;
    setState(() => _isStreaming = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cameraStorageKey, false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePrivacy() => setState(() => _privacyMode = !_privacyMode);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_isStreaming ? AppColors.emerald500 : AppColors.indigo500).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (_isStreaming ? AppColors.emerald500 : AppColors.indigo500).withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.videocam, size: 18, color: _isStreaming ? AppColors.emerald500 : AppColors.indigo500),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text('Patient Live Device Monitor',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                        ),
                        if (_isStreaming) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emerald500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                            ),
                            child: const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.emerald500)),
                          ),
                        ],
                      ],
                    ),
                    Text('Real-time optical feed & patient status oversight',
                        style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isStreaming)
                IconButton(
                  onPressed: _togglePrivacy,
                  tooltip: _privacyMode ? 'Disable Privacy Shield' : 'Enable Privacy Shield',
                  style: IconButton.styleFrom(
                    backgroundColor: _privacyMode ? AppColors.amber500.withValues(alpha: 0.15) : context.subtleBg,
                    side: BorderSide(color: _privacyMode ? AppColors.amber500.withValues(alpha: 0.3) : context.borderColor),
                  ),
                  icon: Icon(_privacyMode ? Icons.visibility_off : Icons.visibility,
                      size: 18, color: _privacyMode ? AppColors.amber500 : context.textSecondaryColor),
                ),
              const SizedBox(width: 8),
              _isStreaming
                  ? OutlinedButton.icon(
                      onPressed: _stopCamera,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rose500,
                        side: BorderSide(color: AppColors.rose500.withValues(alpha: 0.3)),
                      ),
                      icon: const Icon(Icons.videocam_off, size: 14),
                      label: const Text('Stop Feed', style: TextStyle(fontSize: 11)),
                    )
                  : ElevatedButton.icon(
                      onPressed: _startCamera,
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text('Access Device Cam', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: context.isDark ? AppColors.slate950 : AppColors.slate900,
                child: _buildViewport(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewport() {
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.rose500, size: 28),
              const SizedBox(height: 8),
              Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.rose400)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _startCamera,
                icon: const Icon(Icons.refresh, size: 12, color: AppColors.slate300),
                label: const Text('Retry Access', style: TextStyle(fontSize: 11, color: AppColors.slate300)),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isStreaming || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.slate400, size: 26),
            SizedBox(height: 8),
            Text('Camera Feed Off', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 2),
            Text('Tap "Access Device Cam" to monitor patient video.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.slate400)),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize?.height ?? 1,
            height: _controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(_controller!),
          ),
        ),
        if (_privacyMode)
          Container(
            color: AppColors.slate950.withValues(alpha: 0.95),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.amber400, size: 32),
                    const SizedBox(height: 8),
                    const Text('Patient Privacy Shield Active',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Live video transmission is temporarily paused.',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.slate400)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _togglePrivacy,
                      child: const Text('Resume Video Feed', style: TextStyle(fontSize: 11, color: AppColors.amber300)),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.slate950.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PATIENT ROOM CAM #1',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.emerald300)),
                  Text('LIVE', style: TextStyle(fontSize: 9, color: Colors.white70)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
