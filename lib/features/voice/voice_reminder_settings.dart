// ============================================================
// VOICE REMINDER SETTINGS MODEL
// Extends VoiceService with all settings for the premium
// settings page. Ready for SharedPreferences persistence.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/voice_service.dart';

// ──────────────────────────────────────────────
// ENUMS
// ──────────────────────────────────────────────

enum ReminderInterval {
  every5Min('Every 5 minutes', 5),
  every10Min('Every 10 minutes', 10),
  every15Min('Every 15 minutes', 15),
  every30Min('Every 30 minutes', 30),
  every1Hour('Every 1 hour', 60);

  final String label;
  final int minutes;
  const ReminderInterval(this.label, this.minutes);
}

enum GreetingStyle {
  friendly('Friendly & Warm'),
  professional('Professional'),
  concise('Brief & Concise');

  final String label;
  const GreetingStyle(this.label);
}

// ──────────────────────────────────────────────
// VOICE REMINDER SETTINGS MODEL
// ──────────────────────────────────────────────

class VoiceReminderSettings extends ChangeNotifier {
  // ── Core TTS Engine (maps to VoiceService) ──
  bool voiceReminderEnabled = true;
  double volume = 0.8;
  double pitch = 1.0;
  double speechRate = 0.5;
  String selectedLanguage = 'en-US';

  // ── Reminder Behaviour ──
  bool repeatUntilTaken = true;
  ReminderInterval reminderInterval = ReminderInterval.every5Min;

  // ── Greeting Messages ──
  bool morningGreetingEnabled = true;
  String morningGreetingText =
      'Good morning! Time for your morning medications. Stay healthy today!';
  GreetingStyle morningGreetingStyle = GreetingStyle.friendly;

  bool eveningGreetingEnabled = true;
  String eveningGreetingText =
      'Good evening! Don\'t forget your evening medications before bed.';
  GreetingStyle eveningGreetingStyle = GreetingStyle.friendly;

  // ── Silent Mode ──
  bool silentModeEnabled = false;
  TimeOfDay silentModeStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay silentModeEnd = const TimeOfDay(hour: 7, minute: 0);

  // ── Emergency Reminder Volume ──
  /// Override volume for missed/critical dose reminders.
  /// Always plays at max regardless of silent mode.
  double emergencyReminderVolume = 1.0;
  bool emergencyOverrideSilentMode = true;

  // ── Singleton ──
  static final VoiceReminderSettings _instance =
      VoiceReminderSettings._internal();
  factory VoiceReminderSettings() => _instance;
  VoiceReminderSettings._internal();

  // ── Supported languages (mirrors VoiceService list) ──
  final List<Map<String, String>> supportedLanguages =
      VoiceService().supportedLanguages;

  // ── Setters (each notifies UI & saves to local storage) ──
  void setVoiceReminderEnabled(bool value) {
    voiceReminderEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setVolume(double value) {
    volume = value;
    VoiceService().setVolume(value); // keep service in sync
    notifyListeners();
    saveSettings();
  }

  void setPitch(double value) {
    pitch = value;
    VoiceService().setPitch(value);
    notifyListeners();
    saveSettings();
  }

  void setSpeechRate(double value) {
    speechRate = value;
    VoiceService().setRate(value);
    notifyListeners();
    saveSettings();
  }

  void setLanguage(String value) {
    selectedLanguage = value;
    VoiceService().setLanguage(value);
    notifyListeners();
    saveSettings();
  }

  void setRepeatUntilTaken(bool value) {
    repeatUntilTaken = value;
    notifyListeners();
    saveSettings();
  }

  void setReminderInterval(ReminderInterval value) {
    reminderInterval = value;
    notifyListeners();
    saveSettings();
  }

  void setMorningGreetingEnabled(bool value) {
    morningGreetingEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setMorningGreetingText(String value) {
    morningGreetingText = value;
    notifyListeners();
    saveSettings();
  }

  void setMorningGreetingStyle(GreetingStyle value) {
    morningGreetingStyle = value;
    notifyListeners();
    saveSettings();
  }

  void setEveningGreetingEnabled(bool value) {
    eveningGreetingEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setEveningGreetingText(String value) {
    eveningGreetingText = value;
    notifyListeners();
    saveSettings();
  }

  void setEveningGreetingStyle(GreetingStyle value) {
    eveningGreetingStyle = value;
    notifyListeners();
    saveSettings();
  }

  void setSilentModeEnabled(bool value) {
    silentModeEnabled = value;
    notifyListeners();
    saveSettings();
  }

  void setSilentModeStart(TimeOfDay value) {
    silentModeStart = value;
    notifyListeners();
    saveSettings();
  }

  void setSilentModeEnd(TimeOfDay value) {
    silentModeEnd = value;
    notifyListeners();
    saveSettings();
  }

  void setEmergencyReminderVolume(double value) {
    emergencyReminderVolume = value;
    notifyListeners();
    saveSettings();
  }

  void setEmergencyOverrideSilentMode(bool value) {
    emergencyOverrideSilentMode = value;
    notifyListeners();
    saveSettings();
  }

  // ── SharedPreferences Persistence ──
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('voiceReminderEnabled', voiceReminderEnabled);
      await prefs.setDouble('volume', volume);
      await prefs.setDouble('pitch', pitch);
      await prefs.setDouble('speechRate', speechRate);
      await prefs.setString('selectedLanguage', selectedLanguage);
      await prefs.setBool('repeatUntilTaken', repeatUntilTaken);
      await prefs.setInt('reminderInterval', reminderInterval.minutes);
      await prefs.setBool('morningGreetingEnabled', morningGreetingEnabled);
      await prefs.setString('morningGreetingText', morningGreetingText);
      await prefs.setString('morningGreetingStyle', morningGreetingStyle.name);
      await prefs.setBool('eveningGreetingEnabled', eveningGreetingEnabled);
      await prefs.setString('eveningGreetingText', eveningGreetingText);
      await prefs.setString('eveningGreetingStyle', eveningGreetingStyle.name);
      await prefs.setBool('silentModeEnabled', silentModeEnabled);
      await prefs.setInt('silentModeStartHour', silentModeStart.hour);
      await prefs.setInt('silentModeStartMinute', silentModeStart.minute);
      await prefs.setInt('silentModeEndHour', silentModeEnd.hour);
      await prefs.setInt('silentModeEndMinute', silentModeEnd.minute);
      await prefs.setDouble('emergencyReminderVolume', emergencyReminderVolume);
      await prefs.setBool('emergencyOverrideSilentMode', emergencyOverrideSilentMode);
    } catch (e) {
      debugPrint("SharedPreferences write failed: $e");
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      voiceReminderEnabled = prefs.getBool('voiceReminderEnabled') ?? voiceReminderEnabled;
      volume = prefs.getDouble('volume') ?? volume;
      pitch = prefs.getDouble('pitch') ?? pitch;
      speechRate = prefs.getDouble('speechRate') ?? speechRate;
      selectedLanguage = prefs.getString('selectedLanguage') ?? selectedLanguage;
      repeatUntilTaken = prefs.getBool('repeatUntilTaken') ?? repeatUntilTaken;
      
      final intervalMins = prefs.getInt('reminderInterval');
      if (intervalMins != null) {
        reminderInterval = ReminderInterval.values.firstWhere(
          (i) => i.minutes == intervalMins,
          orElse: () => reminderInterval,
        );
      }
      
      morningGreetingEnabled = prefs.getBool('morningGreetingEnabled') ?? morningGreetingEnabled;
      morningGreetingText = prefs.getString('morningGreetingText') ?? morningGreetingText;
      
      final morningStyleName = prefs.getString('morningGreetingStyle');
      if (morningStyleName != null) {
        morningGreetingStyle = GreetingStyle.values.firstWhere(
          (s) => s.name == morningStyleName,
          orElse: () => morningGreetingStyle,
        );
      }
      
      eveningGreetingEnabled = prefs.getBool('eveningGreetingEnabled') ?? eveningGreetingEnabled;
      eveningGreetingText = prefs.getString('eveningGreetingText') ?? eveningGreetingText;
      
      final eveningStyleName = prefs.getString('eveningGreetingStyle');
      if (eveningStyleName != null) {
        eveningGreetingStyle = GreetingStyle.values.firstWhere(
          (s) => s.name == eveningStyleName,
          orElse: () => eveningGreetingStyle,
        );
      }
      
      silentModeEnabled = prefs.getBool('silentModeEnabled') ?? silentModeEnabled;
      
      final startHour = prefs.getInt('silentModeStartHour');
      final startMinute = prefs.getInt('silentModeStartMinute');
      if (startHour != null && startMinute != null) {
        silentModeStart = TimeOfDay(hour: startHour, minute: startMinute);
      }
      
      final endHour = prefs.getInt('silentModeEndHour');
      final endMinute = prefs.getInt('silentModeEndMinute');
      if (endHour != null && endMinute != null) {
        silentModeEnd = TimeOfDay(hour: endHour, minute: endMinute);
      }
      
      emergencyReminderVolume = prefs.getDouble('emergencyReminderVolume') ?? emergencyReminderVolume;
      emergencyOverrideSilentMode = prefs.getBool('emergencyOverrideSilentMode') ?? emergencyOverrideSilentMode;
      
      // Sync engine configurations
      VoiceService().setVolume(volume);
      VoiceService().setPitch(pitch);
      VoiceService().setRate(speechRate);
      VoiceService().setLanguage(selectedLanguage);
    } catch (e) {
      debugPrint("SharedPreferences load failed: $e");
    }
    notifyListeners();
  }

  Map<String, dynamic> toMap() => {
        'voiceReminderEnabled': voiceReminderEnabled,
        'volume': volume,
        'pitch': pitch,
        'speechRate': speechRate,
        'selectedLanguage': selectedLanguage,
        'repeatUntilTaken': repeatUntilTaken,
        'reminderInterval': reminderInterval.minutes,
        'morningGreetingEnabled': morningGreetingEnabled,
        'morningGreetingText': morningGreetingText,
        'morningGreetingStyle': morningGreetingStyle.name,
        'eveningGreetingEnabled': eveningGreetingEnabled,
        'eveningGreetingText': eveningGreetingText,
        'eveningGreetingStyle': eveningGreetingStyle.name,
        'silentModeEnabled': silentModeEnabled,
        'silentModeStartHour': silentModeStart.hour,
        'silentModeStartMinute': silentModeStart.minute,
        'silentModeEndHour': silentModeEnd.hour,
        'silentModeEndMinute': silentModeEnd.minute,
        'emergencyReminderVolume': emergencyReminderVolume,
        'emergencyOverrideSilentMode': emergencyOverrideSilentMode,
      };

  void fromMap(Map<String, dynamic> map) {
    notifyListeners();
  }

  /// Reset all settings to defaults.
  void resetToDefaults() {
    voiceReminderEnabled = true;
    volume = 0.8;
    pitch = 1.0;
    speechRate = 0.5;
    selectedLanguage = 'en-US';
    repeatUntilTaken = true;
    reminderInterval = ReminderInterval.every5Min;
    morningGreetingEnabled = true;
    morningGreetingText =
        'Good morning! Time for your morning medications. Stay healthy today!';
    morningGreetingStyle = GreetingStyle.friendly;
    eveningGreetingEnabled = true;
    eveningGreetingText =
        'Good evening! Don\'t forget your evening medications before bed.';
    eveningGreetingStyle = GreetingStyle.friendly;
    silentModeEnabled = false;
    silentModeStart = const TimeOfDay(hour: 22, minute: 0);
    silentModeEnd = const TimeOfDay(hour: 7, minute: 0);
    emergencyReminderVolume = 1.0;
    emergencyOverrideSilentMode = true;
    notifyListeners();
    saveSettings();
  }
}
