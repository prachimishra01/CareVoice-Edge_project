import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/patient.dart';

class EmergencyManager {
  static final EmergencyManager _instance = EmergencyManager._internal();
  factory EmergencyManager() => _instance;
  EmergencyManager._internal();

  static const _channel = MethodChannel('com.carevoice.edge/telephony');
  static const String _emergencyContactKey = 'carevoice_emergency_contact';

  Timer? _countdownTimer;
  int _secondsRemaining = 10;
  bool _isEmergencyActive = false;
  Patient? _currentPatient;

  // Stream to notify UI of countdown changes
  final _stateController = StreamController<EmergencyState>.broadcast();
  Stream<EmergencyState> get stateStream => _stateController.stream;

  void triggerFallDetection(Patient? patient) {
    if (_isEmergencyActive) return;
    _currentPatient = patient;
    _isEmergencyActive = true;
    _secondsRemaining = 10;

    _notifyState();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        _notifyState();
      } else {
        _executeEmergencyCommunication();
        cancelEmergency();
      }
    });
  }

  void cancelEmergency() {
    _countdownTimer?.cancel();
    _isEmergencyActive = false;
    _notifyState();
  }

  void startImmediateCommunication() {
    _executeEmergencyCommunication();
    cancelEmergency();
  }

  void _notifyState() {
    _stateController.add(EmergencyState(
      isActive: _isEmergencyActive,
      secondsRemaining: _secondsRemaining,
    ));
  }

  Future<void> _executeEmergencyCommunication() async {
    // Priority 1: Load from local storage
    String? number;
    try {
      final prefs = await SharedPreferences.getInstance();
      number = prefs.getString(_emergencyContactKey);
      if (number != null && number.isNotEmpty) {
        debugPrint('DEBUG: Emergency Manager retrieved number from local storage: $number');
      }
    } catch (e) {
      debugPrint('Error retrieving number in EmergencyManager: $e');
    }

    // Fallback to patient object
    number ??= _currentPatient?.emergencyContact;

    if (number == null || number.isEmpty) {
      debugPrint('Emergency aborted: No valid emergency contact number found.');
      return;
    }

    final message = "🚨 CAREVOICE EMERGENCY ALERT:\nA possible fall has been detected for the patient. Please check immediately.";

    try {
      // Trigger existing API alert first
      await apiClient.triggerEmergency(
        patientId: _currentPatient?.id ?? 1,
        triggerSource: 'fall_detection_system',
        speechTranscript: 'Possible fall detected. Automatic emergency communication initiated.',
      );

      // Check permissions
      final smsStatus = await Permission.sms.request();
      final callStatus = await Permission.phone.request();

      if (smsStatus.isGranted) {
        await _channel.invokeMethod('sendNativeSms', {
          'number': number,
          'message': message,
        });
      }

      if (callStatus.isGranted) {
        await _channel.invokeMethod('makeNativeCall', {
          'number': number,
        });
      }
    } catch (e) {
      debugPrint('Failed to initiate emergency communication: $e');
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    _stateController.close();
  }
}

class EmergencyState {
  final bool isActive;
  final int secondsRemaining;

  EmergencyState({required this.isActive, required this.secondsRemaining});
}

final emergencyManager = EmergencyManager();
