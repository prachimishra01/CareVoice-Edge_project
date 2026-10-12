import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/patient.dart';
import '../providers/theme_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

enum MicStage { idle, initializing, listening, processing, success, noSpeech, unable, denied, noMic }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Patient? _patient;
  final _phoneController = TextEditingController();
  final _baseUrlController = TextEditingController();
  bool _isSaving = false;
  bool _isSaved = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  MicStage _micStage = MicStage.idle;
  String? _statusMessage;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _loadPatientContact();
    _baseUrlController.text = apiClient.baseUrl;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _baseUrlController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _loadPatientContact() async {
    try {
      final list = await apiClient.getPatients();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _patient = list.first;
          _phoneController.text = list.first.emergencyContact ?? '';
        });
      }
    } catch (err) {
      debugPrint('Failed to load patient contact settings: $err');
    }
  }

  Future<void> _handleSave() async {
    if (_patient == null) return;
    setState(() {
      _isSaving = true;
      _isSaved = false;
    });
    try {
      final updated = await apiClient.updatePatient(_patient!.id, {'emergency_contact': _phoneController.text});
      setState(() {
        _patient = updated;
        _phoneController.text = updated.emergencyContact ?? '';
        _isSaved = true;
      });
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (mounted) setState(() => _isSaved = false);
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveBaseUrl() async {
    await apiClient.setBaseUrl(_baseUrlController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API base URL saved.')));
    }
  }

  Future<void> _handleTestMicrophone() async {
    setState(() {
      _micStage = MicStage.initializing;
      _statusMessage = 'Initialising microphone...';
      _recognizedText = '';
    });

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      setState(() {
        _micStage = MicStage.denied;
        _statusMessage = 'Microphone permission denied.';
      });
      return;
    }

    final available = await _speech.initialize(
      onError: (err) {
        if (!mounted) return;
        setState(() {
          if (err.errorMsg == 'error_no_match') {
            _micStage = MicStage.noSpeech;
            _statusMessage = 'No speech detected.';
          } else {
            _micStage = MicStage.unable;
            _statusMessage = 'Unable to recognise speech.';
          }
        });
      },
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' && _recognizedText.trim().isEmpty && _micStage == MicStage.listening) {
          setState(() {
            _micStage = MicStage.noSpeech;
            _statusMessage = 'No speech detected.';
          });
        }
      },
    );

    if (!available) {
      if (!mounted) return;
      setState(() {
        _micStage = MicStage.unable;
        _statusMessage = 'Speech recognition unavailable.';
      });
      return;
    }

    setState(() {
      _micStage = MicStage.listening;
      _statusMessage = 'Listening... Speak now.';
    });

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            _micStage = MicStage.success;
            _statusMessage = 'Recognition successful';
          }
        });
      },
      listenOptions: stt.SpeechListenOptions(partialResults: true, listenFor: const Duration(seconds: 8)),
    );
  }

  void _cancelMicTest() {
    _speech.stop();
    setState(() {
      _micStage = MicStage.idle;
      _statusMessage = null;
    });
  }

  Color _micStatusColor() {
    switch (_micStage) {
      case MicStage.success:
      case MicStage.listening:
      case MicStage.processing:
        return AppColors.emerald400;
      case MicStage.initializing:
        return AppColors.indigo400;
      default:
        return AppColors.rose400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _micStage == MicStage.listening || _micStage == MicStage.initializing || _micStage == MicStage.processing;
    final themeProvider = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edge AI Subsystem Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                  Text('Hardware, theme preference & emergency dispatch', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                ],
              ),
            ),
            if (_isSaved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                ),
                child: const Text('Saved!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald400)),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // --- NEW: Appearance & Theme Selection Card ---
        GlassCard(
          borderColor: AppColors.indigo500.withValues(alpha: 0.3),
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
                    ),
                    child: Icon(
                      context.isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 20,
                      color: AppColors.indigo500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appearance & Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                        Text('Select your preferred visual style', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ThemeOptionCard(
                      title: 'Light',
                      icon: Icons.light_mode_rounded,
                      iconColor: AppColors.amber500,
                      isSelected: themeProvider.isLight,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeOptionCard(
                      title: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      iconColor: AppColors.indigo400,
                      isSelected: themeProvider.isDark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeOptionCard(
                      title: 'System',
                      icon: Icons.settings_suggest_rounded,
                      iconColor: AppColors.emerald500,
                      isSelected: themeProvider.isSystem,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // API Connection Card
        GlassCard(
          borderColor: AppColors.indigo500.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi, size: 18, color: AppColors.indigo400),
                  const SizedBox(width: 8),
                  Text('Backend API Connection', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Emulator default: 10.0.2.2:8000. Physical device: use your PC's LAN IP (e.g. http://192.168.1.5:8000/api/v1).",
                style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _baseUrlController,
                style: TextStyle(fontSize: 12, color: context.textPrimaryColor),
                decoration: const InputDecoration(isDense: true, labelText: 'API Base URL'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: _saveBaseUrl, child: const Text('Save Base URL', style: TextStyle(fontSize: 12))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mic Test Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic, size: 18, color: AppColors.indigo400),
                      const SizedBox(width: 8),
                      Text('Microphone Status & Speech Test', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    ],
                  ),
                  isBusy
                      ? OutlinedButton.icon(
                          onPressed: _cancelMicTest,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.rose400, side: BorderSide(color: AppColors.rose500.withValues(alpha: 0.3))),
                          icon: const Icon(Icons.stop, size: 14),
                          label: const Text('Cancel', style: TextStyle(fontSize: 11)),
                        )
                      : ElevatedButton.icon(
                          onPressed: _handleTestMicrophone,
                          icon: const Icon(Icons.mic, size: 14),
                          label: const Text('Test Mic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
              if (_micStage != MicStage.idle) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
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
                          Text('Microphone Status', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                          Text(
                            (_micStage == MicStage.success || _micStage == MicStage.listening || _micStage == MicStage.processing)
                                ? '✓ Microphone Connected'
                                : (_statusMessage ?? ''),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _micStatusColor()),
                          ),
                        ],
                      ),
                      if (_micStage == MicStage.listening) ...[
                        const SizedBox(height: 8),
                        const Text('Speak Something...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigo400)),
                      ],
                      if (_recognizedText.isNotEmpty || _micStage == MicStage.success) ...[
                        const SizedBox(height: 8),
                        Text('RECOGNIZED SPEECH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.textSecondaryColor)),
                        const SizedBox(height: 4),
                        Text('"${_recognizedText.isNotEmpty ? _recognizedText : 'Hello, this is a microphone test.'}"',
                            style: TextStyle(fontSize: 12, color: context.textPrimaryColor, fontStyle: FontStyle.italic)),
                      ],
                      if (_micStage == MicStage.noSpeech || _micStage == MicStage.unable || _micStage == MicStage.denied || _micStage == MicStage.noMic) ...[
                        const SizedBox(height: 8),
                        Text(_statusMessage ?? '', style: const TextStyle(fontSize: 11, color: AppColors.rose500)),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Emergency Phone Call Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_in_talk, size: 18, color: AppColors.rose500),
                  const SizedBox(width: 8),
                  Text('Automatic Emergency Phone Call Dispatch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              Text('CARETAKER EMERGENCY CONTACT NUMBER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                decoration: const InputDecoration(isDense: true, hintText: '+1 (555) 019-2831'),
              ),
              const SizedBox(height: 6),
              Text('Dialed automatically whenever a voice emergency or SOS alert is triggered.',
                  style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: const Icon(Icons.save, size: 16),
                  label: Text(_isSaving ? 'Saving Contact...' : 'Save Emergency Contact Number', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.indigo500.withValues(alpha: context.isDark ? 0.25 : 0.1)
              : context.subtleBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.indigo500 : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.indigo500 : context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
