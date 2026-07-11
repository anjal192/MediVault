import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  // TTS Parameters
  double volume = 0.8; // 0.0 to 1.0
  double pitch = 1.0;  // 0.5 to 2.0
  double rate = 0.5;   // 0.0 to 1.0
  String selectedLanguage = "en-US";
  bool isSpeaking = false;

  // Static list of popular supported languages for user selection
  final List<Map<String, String>> supportedLanguages = [
    {"code": "en-US", "name": "English (United States)"},
    {"code": "en-GB", "name": "English (United Kingdom)"},
    {"code": "es-ES", "name": "Spanish (Spain)"},
    {"code": "fr-FR", "name": "French (France)"},
    {"code": "de-DE", "name": "German (Germany)"},
    {"code": "hi-IN", "name": "Hindi (India)"},
    {"code": "zh-CN", "name": "Chinese (China)"},
  ];

  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;

  VoiceService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      _flutterTts.setStartHandler(() {
        isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        isSpeaking = false;
        notifyListeners();
      });
      
      // Load current parameters
      await updateTtsSettings();
    } catch (e) {
      debugPrint("TTS init failed (simulated container environment): $e");
    }
  }

  // Update TTS parameters
  Future<void> updateTtsSettings() async {
    try {
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setLanguage(selectedLanguage);
    } catch (e) {
      debugPrint("TTS settings update failed: $e");
    }
  }

  // Speak medication text out loud
  Future<void> speakMedicationReminder(String medicineName, String dosage, String instructions) async {
    final text = "Time to take your medication: $medicineName. Dosage is $dosage, $instructions.";
    await speak(text);
  }

  // General speak utility
  Future<void> speak(String text) async {
    try {
      await updateTtsSettings();
      await _flutterTts.speak(text);
    } catch (e) {
      // In simulator, log the output and simulate speaking
      isSpeaking = true;
      notifyListeners();
      debugPrint("SIMULATED TTS SPEAKING: \"$text\" [Lang: $selectedLanguage, Vol: $volume, Pitch: $pitch, Rate: $rate]");
      
      Future.delayed(const Duration(seconds: 3), () {
        isSpeaking = false;
        notifyListeners();
      });
    }
  }

  // Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      isSpeaking = false;
      notifyListeners();
    }
  }

  // Setter helper methods
  void setVolume(double value) {
    volume = value;
    notifyListeners();
  }

  void setPitch(double value) {
    pitch = value;
    notifyListeners();
  }

  void setRate(double value) {
    rate = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    selectedLanguage = value;
    notifyListeners();
  }
}
