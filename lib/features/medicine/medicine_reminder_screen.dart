import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/services/voice_service.dart';
import '../../core/constants/mock_data.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  late final MediVaultRepository _repository;
  late final VoiceService _voiceService;
  
  bool _repeatReminders = true;

  @override
  void initState() {
    super.initState();
    _repository = MediVaultRepository();
    _voiceService = VoiceService();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medication Reminders"),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_repository, _voiceService]),
        builder: (context, _) {
          final todayMeds = _repository.todayMedicines;

          return GradientBackground(
            style: BackgroundStyle.pillPattern,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // 1. Voice Settings panel (Smart Voice Reminder Configuration)
                _buildVoiceSettingsPanel(isDark),
                const SizedBox(height: 24),

                // Header
                const Text(
                  "Today's Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),

                // 2. Schedule list
                if (todayMeds.isEmpty)
                  const GlassCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text("All clean! No scheduled medicines remaining today."),
                      ),
                    ),
                  )
                else
                  ...todayMeds.map((med) => _buildMedicineReminderCard(med, isDark)),
                  
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceSettingsPanel(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryGreen.withAlpha(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.volume_up, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    "Voice Settings (TTS)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppTheme.primaryGreen, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Advanced Voice Settings",
                    onPressed: () {
                      Navigator.pushNamed(context, '/voice-settings');
                    },
                  ),
                ],
              ),
              // Repeat toggle
              Row(
                children: [
                  const Text("Repeat (5m)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Switch(
                    value: _repeatReminders,
                    activeThumbColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _repeatReminders = val);
                    },
                  )
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          
          // Language selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Voice Language:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withAlpha(100)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _voiceService.selectedLanguage,
                    items: _voiceService.supportedLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _voiceService.setLanguage(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Pitch slider
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Voice Pitch", style: TextStyle(fontSize: 12))),
              Expanded(
                child: Slider(
                  value: _voiceService.pitch,
                  min: 0.5,
                  max: 2.0,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) => _voiceService.setPitch(val),
                ),
              ),
              Text(_voiceService.pitch.toStringAsFixed(1), style: const TextStyle(fontSize: 11)),
            ],
          ),
          
          // Speech rate slider
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Speech Rate", style: TextStyle(fontSize: 12))),
              Expanded(
                child: Slider(
                  value: _voiceService.rate,
                  min: 0.0,
                  max: 1.0,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) => _voiceService.setRate(val),
                ),
              ),
              Text(_voiceService.rate.toStringAsFixed(1), style: const TextStyle(fontSize: 11)),
            ],
          ),

          const SizedBox(height: 8),
          
          // Test button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _voiceService.speak("This is a test of the MediVault Smart Voice assistant reminder.");
              },
              icon: Icon(
                _voiceService.isSpeaking ? Icons.record_voice_over : Icons.play_arrow_rounded,
                size: 16,
              ),
              label: Text(_voiceService.isSpeaking ? "Speaking..." : "Test Voice Engine"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineReminderCard(Medicine med, bool isDark) {
    Color statusColor;
    switch (med.stockStatus) {
      case 'Red':
        statusColor = AppTheme.statusRed;
        break;
      case 'Yellow':
        statusColor = AppTheme.statusYellow;
        break;
      default:
        statusColor = AppTheme.statusGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        color: med.isTaken
            ? Colors.grey.withAlpha(15)
            : med.isSkipped
                ? AppTheme.statusRed.withAlpha(10)
                : null,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: med.isTaken ? Colors.grey.withAlpha(40) : AppTheme.primaryGreen.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    med.iconName == 'capsule'
                        ? Icons.hourglass_empty
                        : med.iconName == 'tablet'
                            ? Icons.circle_outlined
                            : Icons.medication_liquid,
                    color: med.isTaken ? Colors.grey : AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              med.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: med.isTaken ? TextDecoration.lineThrough : null,
                                color: med.isTaken ? Colors.grey : null,
                              ),
                            ),
                          ),
                          // Voice reading button
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 20, color: AppTheme.primaryGreen),
                            onPressed: () {
                              _voiceService.speakMedicationReminder(
                                med.name,
                                med.dosage,
                                med.beforeFood ? "before food" : "after food",
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        "${med.dosage} • Scheduled: ${med.time}",
                        style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: med.beforeFood ? Colors.orange.withAlpha(20) : Colors.blue.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              med.beforeFood ? "Before Food" : "After Food",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: med.beforeFood ? Colors.orange : Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (med.isPrescribed)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Prescribed",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 20),
            
            // Interaction Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${med.remainingQuantity} left (Est: ${med.daysLeft} days)",
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                // Action Buttons
                Row(
                  children: [
                    // Skip button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: med.isSkipped ? Colors.white : AppTheme.statusRed,
                        backgroundColor: med.isSkipped ? AppTheme.statusRed : null,
                        side: BorderSide(color: AppTheme.statusRed.withAlpha(100)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _repository.skipMedicine(med.id),
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text("Skip", style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 10),
                    // Taken button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: med.isTaken ? Colors.grey : AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      onPressed: med.isTaken ? null : () => _repository.takeMedicine(med.id),
                      icon: const Icon(Icons.check, size: 14),
                      label: Text(med.isTaken ? "Taken" : "Take", style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
