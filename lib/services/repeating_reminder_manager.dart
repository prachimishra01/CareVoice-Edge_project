import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'api_client.dart';
import 'tts_service.dart';

/// Port of frontend/src/utils/repeatingReminderManager.ts using speech_to_text
/// in place of the browser's Web Speech Recognition API.
enum ReminderState {
  scheduled,
  active,
  repeating,
  listeningForConfirmation,
  completed,
  cancelled,
}

class ActiveReminderStatus {
  final int? reminderId;
  final String title;
  final String audioPrompt;
  final ReminderState state;
  final int secondsUntilRepeat;
  final String? speechTranscript;
  final String? completionMessage;
  final String? micError;

  const ActiveReminderStatus({
    this.reminderId,
    this.title = '',
    this.audioPrompt = '',
    this.state = ReminderState.scheduled,
    this.secondsUntilRepeat = 5,
    this.speechTranscript,
    this.completionMessage,
    this.micError,
  });

  ActiveReminderStatus copyWith({
    int? reminderId,
    String? title,
    String? audioPrompt,
    ReminderState? state,
    int? secondsUntilRepeat,
    String? speechTranscript,
    String? completionMessage,
    String? micError,
  }) {
    return ActiveReminderStatus(
      reminderId: reminderId ?? this.reminderId,
      title: title ?? this.title,
      audioPrompt: audioPrompt ?? this.audioPrompt,
      state: state ?? this.state,
      secondsUntilRepeat: secondsUntilRepeat ?? this.secondsUntilRepeat,
      speechTranscript: speechTranscript ?? this.speechTranscript,
      completionMessage: completionMessage ?? this.completionMessage,
      micError: micError,
    );
  }
}

const List<String> _completionPhrases = [
  'task done',
  'done',
  'completed',
  'i have completed it',
  'finished',
  'yes, completed',
  'taken',
  'took',
  'i did',
  'yes',
  'already done',
];

class RepeatingReminderManager extends ChangeNotifier {
  ActiveReminderStatus _status = const ActiveReminderStatus();
  Timer? _timerInterval;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listeningActive = false;

  ActiveReminderStatus get status => _status;

  void _emit() {
    notifyListeners();
  }

  Future<void> startRepeatingReminder(int reminderId, String title, String audioPrompt) async {
    if (_status.reminderId == reminderId &&
        (_status.state == ReminderState.active || _status.state == ReminderState.repeating)) {
      debugPrint('[Reminder Loop] Reminder #$reminderId is already repeating.');
      return;
    }

    await stopAll();

    final fullPromptText = 'Reminder. It is time to take your $title. $audioPrompt';

    _status = ActiveReminderStatus(
      reminderId: reminderId,
      title: title,
      audioPrompt: fullPromptText,
      state: ReminderState.active,
      secondsUntilRepeat: 5,
    );
    _emit();

    debugPrint('[Reminder Loop] Starting persistent 5s repeating reminder for #$reminderId: "$title"');

    // 1. Initial TTS Announcement
    unawaited(ttsService.speak(fullPromptText));

    // 2. Start Microphone Speech Recognition
    unawaited(_startMicrophoneListening());

    // 3. Start 5-second interval repeat timer
    _timerInterval = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status.state != ReminderState.active &&
          _status.state != ReminderState.repeating &&
          _status.state != ReminderState.listeningForConfirmation) {
        _stopTimer();
        return;
      }

      final remaining = _status.secondsUntilRepeat - 1;
      if (remaining <= 0) {
        _status = _status.copyWith(secondsUntilRepeat: 5, state: ReminderState.repeating);
        _emit();
        debugPrint('[Reminder Loop] 5s Repeat Interval elapsed. Re-announcing reminder #$reminderId...');
        unawaited(ttsService.speak(fullPromptText));
      } else {
        _status = _status.copyWith(secondsUntilRepeat: remaining);
        _emit();
      }
    });
  }

  Future<void> _startMicrophoneListening() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (err) {
          debugPrint('[SpeechRec Error] ${err.errorMsg}');
          _status = _status.copyWith(micError: 'Speech recognition note: ${err.errorMsg}');
          _emit();
          if (_status.state == ReminderState.active ||
              _status.state == ReminderState.repeating ||
              _status.state == ReminderState.listeningForConfirmation) {
            _restartListening();
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listeningActive = false;
            if (_status.state == ReminderState.active ||
                _status.state == ReminderState.repeating ||
                _status.state == ReminderState.listeningForConfirmation) {
              _restartListening();
            }
          }
        },
      );
    } catch (err) {
      debugPrint('[SpeechRec Exception] Failed to initialize microphone listener: $err');
      _status = _status.copyWith(micError: 'Microphone listener initialization note.');
      _emit();
      return;
    }

    if (!_speechAvailable) {
      debugPrint('[SpeechRec Error] Speech recognition unavailable on this device.');
      _status = _status.copyWith(micError: 'Microphone API unavailable on this device.');
      _emit();
      return;
    }

    _beginListen();
  }

  void _restartListening() {
    if (_listeningActive) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_status.state == ReminderState.active ||
          _status.state == ReminderState.repeating ||
          _status.state == ReminderState.listeningForConfirmation) {
        _beginListen();
      }
    });
  }

  void _beginListen() {
    if (!_speechAvailable || _listeningActive) return;
    _listeningActive = true;
    if (_status.state == ReminderState.active || _status.state == ReminderState.repeating) {
      _status = _status.copyWith(state: ReminderState.listeningForConfirmation, micError: null);
      _emit();
    }
    debugPrint('[SpeechRec] Microphone active. Listening for voice confirmation...');
    _speech.listen(
      onResult: (result) {
        final lowerTranscript = result.recognizedWords.toLowerCase().trim();
        if (lowerTranscript.isEmpty) return;
        debugPrint('[SpeechRec Transcript] Spoken input: "$lowerTranscript"');
        _status = _status.copyWith(speechTranscript: lowerTranscript);
        _emit();

        final isMatched = _completionPhrases.any((phrase) => lowerTranscript.contains(phrase));
        if (isMatched) {
          debugPrint('[SpeechRec Matched] Valid voice confirmation phrase detected: "$lowerTranscript"');
          confirmCompletion(lowerTranscript);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> confirmCompletion([String spokenText = 'Done']) async {
    if (_status.reminderId == null) return;

    final currentId = _status.reminderId!;
    final currentTitle = _status.title;

    debugPrint('[Reminder Loop] Confirming completion for Reminder #$currentId with spoken phrase: "$spokenText"');

    await stopAll();

    const confirmMsg = 'Thank you. Your task has been marked as completed.';
    _status = ActiveReminderStatus(
      reminderId: currentId,
      title: currentTitle,
      audioPrompt: '',
      state: ReminderState.completed,
      secondsUntilRepeat: 0,
      speechTranscript: spokenText,
      completionMessage: confirmMsg,
    );
    _emit();

    try {
      await apiClient.confirmVoice(currentId, spokenText);
    } catch (err) {
      debugPrint('Failed to record completion API: $err');
    }

    unawaited(ttsService.speak(confirmMsg));
  }

  void _stopTimer() {
    _timerInterval?.cancel();
    _timerInterval = null;
  }

  Future<void> _stopMicrophone() async {
    _listeningActive = false;
    try {
      await _speech.stop();
    } catch (_) {}
  }

  Future<void> stopAll() async {
    _stopTimer();
    await _stopMicrophone();
  }
}

final repeatingReminderManager = RepeatingReminderManager();
