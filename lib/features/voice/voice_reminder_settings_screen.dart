import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/voice_service.dart';
import 'voice_reminder_settings.dart';
import 'widgets/settings_tiles.dart';

/// Premium Voice Reminder Settings Screen
/// Extends the Voice Reminder module with a high-fidelity control dashboard.
/// Configures text-to-speech parameters and reminder behavior.
class VoiceReminderSettingsScreen extends StatefulWidget {
  const VoiceReminderSettingsScreen({super.key});

  @override
  State<VoiceReminderSettingsScreen> createState() => _VoiceReminderSettingsScreenState();
}

class _VoiceReminderSettingsScreenState extends State<VoiceReminderSettingsScreen> {
  late final VoiceReminderSettings _settings;
  late final VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _settings = VoiceReminderSettings();
    _voiceService = VoiceService();
  }

  void _onTestVoice() {
    if (!_settings.voiceReminderEnabled) return;
    _voiceService.speak("This is a test of the MediVault Smart Voice assistant engine.");
  }

  void _onPreviewReminder() {
    if (!_settings.voiceReminderEnabled) return;
    const text = "Time to take your medication: Aspirin. Dosage is 1 tablet, after food.";
    _voiceService.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: "Reset to defaults",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Reset Settings"),
                  content: const Text("Are you sure you want to reset all voice settings to their defaults?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        _settings.resetToDefaults();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Settings reset to defaults"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: const Text("Reset", style: TextStyle(color: AppTheme.statusRed)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final enabled = _settings.voiceReminderEnabled;

          return GradientBackground(
            style: BackgroundStyle.pillPattern,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                // Info banner
                const InfoSettingsTile(
                  message: "Configure text-to-speech engine rules and customized greetings. These settings control automatic voice announcements for all prescription reminders.",
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 12),

                // Master Toggle
                SwitchSettingsTile(
                  icon: Icons.record_voice_over_rounded,
                  title: "Enable Voice Reminders",
                  description: "Announce medications out loud using text-to-speech",
                  value: enabled,
                  onChanged: _settings.setVoiceReminderEnabled,
                  accentColor: AppTheme.primaryGreen,
                ),

                // ──────────────────────────────────────────────
                // SECTION: TTS ENGINE PROPERTIES
                // ──────────────────────────────────────────────
                const SettingsSectionHeader(
                  icon: Icons.tune_rounded,
                  title: "Speech Engine Settings",
                  subtitle: "Customize how the voice assistant sounds",
                  color: AppTheme.accentBlue,
                ),

                // Select Language
                DropdownSettingsTile<String>(
                  icon: Icons.translate_rounded,
                  title: "Voice Language",
                  description: "Language dialect for speaking",
                  value: _settings.selectedLanguage,
                  isEnabled: enabled,
                  accentColor: AppTheme.accentBlue,
                  items: _settings.supportedLanguages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code'],
                      child: Text(lang['name']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _settings.setLanguage(val);
                  },
                ),
                const SizedBox(height: 12),

                // Volume Slider
                SliderSettingsTile(
                  icon: Icons.volume_up_rounded,
                  title: "Speech Volume",
                  description: "Volume of standard speech announcements",
                  value: _settings.volume,
                  min: 0.0,
                  max: 1.0,
                  isEnabled: enabled,
                  accentColor: AppTheme.accentBlue,
                  valueLabel: (val) => "${(val * 100).toInt()}%",
                  onChanged: _settings.setVolume,
                ),
                const SizedBox(height: 12),

                // Speech Rate Slider
                SliderSettingsTile(
                  icon: Icons.speed_rounded,
                  title: "Speech Rate",
                  description: "Speed level of voice assistant announcements",
                  value: _settings.speechRate,
                  min: 0.2,
                  max: 1.0,
                  isEnabled: enabled,
                  accentColor: AppTheme.accentBlue,
                  valueLabel: (val) {
                    if (val < 0.4) return "Slow";
                    if (val > 0.7) return "Fast";
                    return "Normal";
                  },
                  onChanged: _settings.setSpeechRate,
                ),
                const SizedBox(height: 12),

                // Pitch Slider
                SliderSettingsTile(
                  icon: Icons.height_rounded,
                  title: "Speech Pitch",
                  description: "Voice pitch level adjustments",
                  value: _settings.pitch,
                  min: 0.5,
                  max: 2.0,
                  isEnabled: enabled,
                  accentColor: AppTheme.accentBlue,
                  valueLabel: (val) {
                    if (val < 0.8) return "Low Pitch";
                    if (val > 1.3) return "High Pitch";
                    return "Default";
                  },
                  onChanged: _settings.setPitch,
                ),

                // ── Preview & Test Cards ──
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: enabled ? AppTheme.accentBlue : Colors.grey,
                          side: BorderSide(color: (enabled ? AppTheme.accentBlue : Colors.grey).withAlpha(80)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: enabled ? _onTestVoice : null,
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text("Test Engine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enabled ? AppTheme.primaryGreen : Colors.grey,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: enabled ? _onPreviewReminder : null,
                        icon: const Icon(Icons.volume_up_rounded, size: 16),
                        label: const Text("Preview Reminder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),

                // ──────────────────────────────────────────────
                // SECTION: BEHAVIOR RULES
                // ──────────────────────────────────────────────
                const SettingsSectionHeader(
                  icon: Icons.alarm_rounded,
                  title: "Reminder Behavior",
                  subtitle: "Define intervals and repetition settings",
                  color: AppTheme.primaryGreen,
                ),

                // Repeat Until Taken
                SwitchSettingsTile(
                  icon: Icons.repeat_rounded,
                  title: "Repeat Until Taken",
                  description: "Keep reminding periodically until medicine is logged",
                  value: _settings.repeatUntilTaken,
                  isEnabled: enabled,
                  onChanged: _settings.setRepeatUntilTaken,
                  accentColor: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 12),

                // Reminder Interval
                DropdownSettingsTile<ReminderInterval>(
                  icon: Icons.hourglass_top_rounded,
                  title: "Reminder Interval",
                  description: "Minutes between announcement alerts",
                  value: _settings.reminderInterval,
                  isEnabled: enabled && _settings.repeatUntilTaken,
                  accentColor: AppTheme.primaryGreen,
                  items: ReminderInterval.values.map((interval) {
                    return DropdownMenuItem<ReminderInterval>(
                      value: interval,
                      child: Text(interval.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _settings.setReminderInterval(val);
                  },
                ),

                // ──────────────────────────────────────────────
                // SECTION: CUSTOM GREETINGS
                // ──────────────────────────────────────────────
                const SettingsSectionHeader(
                  icon: Icons.wb_sunny_outlined,
                  title: "Greeting & Salutations",
                  subtitle: "Customize morning and evening introductory alerts",
                  color: Colors.orange,
                ),

                // Morning Greeting Toggle
                SwitchSettingsTile(
                  icon: Icons.wb_sunny_rounded,
                  title: "Morning Greeting",
                  description: "Greet user during morning reminders (6 AM - 12 PM)",
                  value: _settings.morningGreetingEnabled,
                  isEnabled: enabled,
                  onChanged: _settings.setMorningGreetingEnabled,
                  accentColor: Colors.orange,
                ),
                const SizedBox(height: 12),

                // Morning Greeting Style
                DropdownSettingsTile<GreetingStyle>(
                  icon: Icons.style_rounded,
                  title: "Greeting Tone",
                  description: "Greeting style type for morning announcements",
                  value: _settings.morningGreetingStyle,
                  isEnabled: enabled && _settings.morningGreetingEnabled,
                  accentColor: Colors.orange,
                  items: GreetingStyle.values.map((style) {
                    return DropdownMenuItem<GreetingStyle>(
                      value: style,
                      child: Text(style.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _settings.setMorningGreetingStyle(val);
                  },
                ),
                const SizedBox(height: 12),

                // Morning Greeting Text Editor
                TextFieldSettingsTile(
                  icon: Icons.edit_note_rounded,
                  title: "Custom Morning Phrase",
                  hintText: "Enter morning greeting text...",
                  initialValue: _settings.morningGreetingText,
                  isEnabled: enabled && _settings.morningGreetingEnabled,
                  accentColor: Colors.orange,
                  onChanged: _settings.setMorningGreetingText,
                ),
                const SizedBox(height: 20),

                // Evening Greeting Toggle
                SwitchSettingsTile(
                  icon: Icons.nights_stay_rounded,
                  title: "Evening Greeting",
                  description: "Greet user during evening reminders (6 PM - 10 PM)",
                  value: _settings.eveningGreetingEnabled,
                  isEnabled: enabled,
                  onChanged: _settings.setEveningGreetingEnabled,
                  accentColor: Colors.purple,
                ),
                const SizedBox(height: 12),

                // Evening Greeting Text Editor
                TextFieldSettingsTile(
                  icon: Icons.edit_note_rounded,
                  title: "Custom Evening Phrase",
                  hintText: "Enter evening greeting text...",
                  initialValue: _settings.eveningGreetingText,
                  isEnabled: enabled && _settings.eveningGreetingEnabled,
                  accentColor: Colors.purple,
                  onChanged: _settings.setEveningGreetingText,
                ),

                // ──────────────────────────────────────────────
                // SECTION: SILENT MODE
                // ──────────────────────────────────────────────
                const SettingsSectionHeader(
                  icon: Icons.do_not_disturb_on_rounded,
                  title: "Silent & Quiet Hours",
                  subtitle: "Temporarily pause spoken announcements during specific periods",
                  color: Colors.indigo,
                ),

                // Silent Mode Toggle
                SwitchSettingsTile(
                  icon: Icons.nights_stay_outlined,
                  title: "Silent Mode Active",
                  description: "Mute voice announcements during sleep hours",
                  value: _settings.silentModeEnabled,
                  isEnabled: enabled,
                  onChanged: _settings.setSilentModeEnabled,
                  accentColor: Colors.indigo,
                ),
                const SizedBox(height: 12),

                // Time Pickers
                TimeRangeSettingsTile(
                  icon: Icons.schedule_rounded,
                  title: "Silent Period Range",
                  description: "Set active start/end hours of quiet period",
                  startTime: _settings.silentModeStart,
                  endTime: _settings.silentModeEnd,
                  isEnabled: enabled && _settings.silentModeEnabled,
                  accentColor: Colors.indigo,
                  onStartChanged: _settings.setSilentModeStart,
                  onEndChanged: _settings.setSilentModeEnd,
                ),

                // ──────────────────────────────────────────────
                // SECTION: CRITICAL / SOS OVERRIDES
                // ──────────────────────────────────────────────
                const SettingsSectionHeader(
                  icon: Icons.warning_rounded,
                  title: "Critical & SOS Overrides",
                  subtitle: "Rule settings for emergency reminders",
                  color: AppTheme.statusRed,
                ),

                // Emergency Volume Slider
                SliderSettingsTile(
                  icon: Icons.emergency_rounded,
                  title: "Emergency Reminder Volume",
                  description: "Override volume for missed or critical medication alerts",
                  value: _settings.emergencyReminderVolume,
                  min: 0.0,
                  max: 1.0,
                  isEnabled: enabled,
                  accentColor: AppTheme.statusRed,
                  valueLabel: (val) => "${(val * 100).toInt()}%",
                  onChanged: _settings.setEmergencyReminderVolume,
                ),
                const SizedBox(height: 12),

                // Override Silent Mode
                SwitchSettingsTile(
                  icon: Icons.volume_up_rounded,
                  title: "Bypass Silent Mode",
                  description: "Announce emergency reminders even during silent hours",
                  value: _settings.emergencyOverrideSilentMode,
                  isEnabled: enabled,
                  onChanged: _settings.setEmergencyOverrideSilentMode,
                  accentColor: AppTheme.statusRed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
