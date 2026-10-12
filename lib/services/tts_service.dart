import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Port of frontend/src/utils/tts.ts (Web Speech API) using flutter_tts,
/// which routes audio to the device's default speaker/headphone output.
enum TtsStatus {
  idle,
  initializing,
  generating,
  playing,
  unavailable,
  blocked,
  failed,
}

extension TtsStatusLabel on TtsStatus {
  String get label {
    switch (this) {
      case TtsStatus.idle:
        return 'Idle';
      case TtsStatus.initializing:
        return 'Initializing speech engine...';
      case TtsStatus.generating:
        return 'Generating speech...';
      case TtsStatus.playing:
        return 'Playing reminder...';
      case TtsStatus.unavailable:
        return 'Audio output unavailable.';
      case TtsStatus.blocked:
        return 'Browser blocked audio playback.';
      case TtsStatus.failed:
        return 'Speech synthesis failed.';
    }
  }
}

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  TtsStatus _status = TtsStatus.idle;
  String _spokenText = '';
  bool _initialized = false;

  TtsStatus get status => _status;
  String get spokenText => _spokenText;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    _flutterTts.setStartHandler(() {
      _setStatus(TtsStatus.playing);
    });
    _flutterTts.setCompletionHandler(() {
      _setStatus(TtsStatus.idle);
    });
    _flutterTts.setErrorHandler((msg) {
      debugPrint('[TTS Engine Error] $msg');
      _setStatus(TtsStatus.failed);
    });
  }

  void _setStatus(TtsStatus status, [String? text]) {
    _status = status;
    if (text != null) _spokenText = text;
    notifyListeners();
  }

  Future<bool> speak(String text) async {
    debugPrint('[TTS Engine] Initiating speech synthesis for: "$text"');
    _setStatus(TtsStatus.initializing, text);
    try {
      await _ensureInit();
      await _flutterTts.stop();
      _setStatus(TtsStatus.generating, text);
      final result = await _flutterTts.speak(text);
      if (result != 1) {
        _setStatus(TtsStatus.failed, text);
        return false;
      }
      return true;
    } catch (err) {
      debugPrint('[TTS Engine Exception] $err');
      _setStatus(TtsStatus.failed, text);
      return false;
    }
  }

  Future<bool> testSpeaker() async {
    const testSentence = 'This is a reminder speaker test. Your audio output is working correctly.';
    return speak(testSentence);
  }
}

final ttsService = TtsService();
