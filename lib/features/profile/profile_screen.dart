import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = MediVaultRepository();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final todayMeds = repo.todayMedicines;
          final adherence = repo.adherenceProgress;
          final totalMeds = repo.medicines.length;

          return GradientBackground(
            style: BackgroundStyle.glowingOrbs,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // 1. Large Profile Card with Completion Ring
                _buildProfileCard(repo.userName, repo.userEmail, repo.profileCompletion, isDark),
                const SizedBox(height: 20),

                // 2. Health & Medicine Stats Box
                _buildStatsCard(todayMeds.length, totalMeds, adherence),
                const SizedBox(height: 24),

                // 3. Settings Categories
                _buildSettingsHeader("Health Dashboard"),
                _buildSettingsTile(context, Icons.history_edu, "Personal Health Record", "Allergies, conditions, surgeries", "/health-record"),
                _buildSettingsTile(context, Icons.calendar_month, "Doctor Appointments", "Schedule and clinic visits", "/dashboard"),
                _buildSettingsTile(context, Icons.folder_shared, "Prescription Archive", "Simplified uploads and logs", "/vault"),
                
                const SizedBox(height: 16),
                _buildSettingsHeader("App Preferences"),
                _buildSettingsTile(context, Icons.volume_up, "Voice Reminder (TTS) Settings", "Speech volume, pitch, speed", "/reminders"),
                _buildSettingsTile(context, Icons.translate, "App Language", "English (US)", null, trailingText: "English"),
                _buildSettingsTile(context, Icons.notifications_active_outlined, "Notification Settings", "Low stock & daily reminder alerts", null, hasSwitch: true),
                
                const SizedBox(height: 16),
                _buildSettingsHeader("Support & Privacy"),
                _buildSettingsTile(context, Icons.security, "Privacy & Terms", "Data encryption rules", null),
                _buildSettingsTile(context, Icons.help_outline, "Help Center", "FAQs and user support manuals", null),
                
                const SizedBox(height: 24),
                
                // Logout button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.statusRed,
                    side: const BorderSide(color: AppTheme.statusRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out from Device", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(String name, String email, int completion, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          // Large avatar + ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: completion / 100.0,
                  strokeWidth: 4,
                  backgroundColor: AppTheme.primaryGreen.withAlpha(30),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryGreen.withAlpha(20),
                child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 36),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Profile Complete: $completion%",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsCard(int activeMeds, int totalMeds, double adherence) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Active Meds", "$activeMeds / $totalMeds"),
          _buildDivider(),
          _buildStatItem("Today Adherence", "${(adherence * 100).toInt()}%"),
          _buildDivider(),
          _buildStatItem("Health Score", "92/100"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withAlpha(50),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    String? route, {
    String? trailingText,
    bool hasSwitch = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))
            else if (hasSwitch)
              StatefulBuilder(
                builder: (context, setSwitchState) {
                  bool notifActive = true;
                  return Switch(
                    value: notifActive,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setSwitchState(() => notifActive = val);
                    },
                  );
                },
              )
            else if (route != null)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
